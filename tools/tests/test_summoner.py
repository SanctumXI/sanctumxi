"""Isolated Sanctum Summoner regressions; no database or game server required."""

import ctypes
import ctypes.util
import json
import re
import sqlite3
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / "modules/sanctum/jobs/summoner"


def rows(table, path=None):
    source = (ROOT / (path or f"sql/{table}.sql")).read_text(encoding="utf-8-sig")
    schema = (ROOT / f"sql/{table}.sql").read_text(encoding="utf-8-sig")
    schema = re.search(r"CREATE TABLE[^\n]+\(\n(.*?)\n\)", schema, re.S).group(1)
    columns = re.findall(r"^\s*`([^`]+)`", schema, re.M)
    variables = {
        key: int(value)
        for key, value in re.findall(r"SET\s+(@\w+)\s*=\s*(\d+)", source)
    }
    result = []
    for line in source.splitlines():
        match = re.match(rf"INSERT INTO `{table}` VALUES \((.*?)\);", line)
        if not match:
            continue
        values = []
        for token in re.findall(r"'(?:[^'\\]|\\.|'')*'|[^,]+", match.group(1)):
            token = token.strip()
            if token.startswith("'"):
                value = token[1:-1]
            elif token == "NULL":
                value = None
            elif token.startswith("0x"):
                value = bytes.fromhex(token[2:])
            elif token.startswith("@"):
                value = 0
                for flag in token.split("|"):
                    value |= variables[flag.strip()]
            else:
                value = float(token) if "." in token else int(token)
            values.append(value)
        assert len(columns) == len(values), line
        result.append(dict(zip(columns, values)))
    return result


def database():
    connection = sqlite3.connect(":memory:")
    connection.create_function("REPEAT", 2, lambda value, count: value * count)
    connection.create_function("UNHEX", 1, bytes.fromhex)
    tables = {
        "abilities": ("abilityId", "name", "job", "level"),
        "pet_skills": (
            "pet_skill_id",
            "pet_skill_name",
            "pet_skill_flag",
            "pet_prepare_time",
        ),
        "spell_list": ("spellid", "name", "jobs"),
        "mob_spell_lists": ("spell_list_id", "spell_id", "min_level", "max_level"),
        "skill_ranks": ("skillid", "name", "smn"),
    }
    for name, columns in tables.items():
        connection.execute(f'CREATE TABLE {name} ({", ".join(columns)})')
        data = rows(name)
        if name == "abilities":
            merged = {row["abilityId"]: row for row in data}
            merged.update(
                {
                    row["abilityId"]: row
                    for row in rows(
                        name, "modules/sanctum/CombatRework/SQL/Jobs/abilities.sql"
                    )
                }
            )
            data = list(merged.values())
        connection.executemany(
            f'INSERT INTO {name} VALUES ({", ".join("?" for _ in columns)})',
            [tuple(row[column] for column in columns) for row in data],
        )
    return connection


def lua_library():
    bundled = ROOT / "libluajit_64.dll"
    name = (
        str(bundled)
        if hasattr(ctypes, "WinDLL")
        else ctypes.util.find_library("luajit-5.1")
    )
    if not name:
        raise RuntimeError(
            "Install LuaJIT or run with the repository bundled Windows DLL."
        )
    library = ctypes.CDLL(name)
    pointer = ctypes.c_void_p
    library.luaL_newstate.restype = pointer
    library.luaL_openlibs.argtypes = [pointer]
    library.luaL_loadbuffer.argtypes = [
        pointer,
        ctypes.c_char_p,
        ctypes.c_size_t,
        ctypes.c_char_p,
    ]
    library.luaL_loadbuffer.restype = ctypes.c_int
    library.lua_pcall.argtypes = [pointer, ctypes.c_int, ctypes.c_int, ctypes.c_int]
    library.lua_pcall.restype = ctypes.c_int
    library.lua_tolstring.argtypes = [pointer, ctypes.c_int, pointer]
    library.lua_tolstring.restype = ctypes.c_char_p
    library.lua_getfield.argtypes = [pointer, ctypes.c_int, ctypes.c_char_p]
    library.lua_settop.argtypes = [pointer, ctypes.c_int]
    library.lua_close.argtypes = [pointer]
    return library


class SummonerTests(unittest.TestCase):
    def test_sql_scope_and_repeatability(self):
        with database() as connection:
            before = dict(
                connection.execute(
                    "SELECT pet_skill_id, pet_skill_flag FROM pet_skills"
                )
            )
            sql = (MODULE / "summoner.sql").read_text()
            connection.executescript(sql)
            once = "\n".join(connection.iterdump())
            connection.executescript(sql)
            self.assertEqual(once, "\n".join(connection.iterdump()))

            eligible = {
                row[0]
                for row in connection.execute(
                    "SELECT abilityId FROM abilities WHERE job = 15 AND level <= 75"
                )
            }
            after = dict(
                connection.execute(
                    "SELECT pet_skill_id, pet_skill_flag FROM pet_skills"
                )
            )
            for identifier, flag in before.items():
                expected = flag & ~4 if identifier in eligible and flag & 192 else flag
                self.assertEqual(after[identifier], expected, identifier)
            self.assertEqual(after[551] & 4, 0)
            self.assertNotEqual(after[519] & 4, 0)  # Above the 75 cap.
            for identifier in eligible:
                if identifier in after and after[identifier] & 192:
                    self.assertEqual(
                        connection.execute(
                            "SELECT pet_prepare_time FROM pet_skills WHERE pet_skill_id = ?",
                            (identifier,),
                        ).fetchone()[0],
                        500,
                    )
            self.assertEqual(
                connection.execute(
                    "SELECT smn FROM skill_ranks WHERE skillid = 38"
                ).fetchone()[0],
                1,
            )
            self.assertEqual(
                connection.execute(
                    "SELECT level FROM abilities WHERE abilityId = 385"
                ).fetchone()[0],
                255,
            )
            for identifier, level in ((553, 55), (618, 60), (569, 65)):
                self.assertEqual(
                    connection.execute(
                        "SELECT level FROM abilities WHERE abilityId = ?", (identifier,)
                    ).fetchone()[0],
                    level,
                )
            for identifier in (306, 847):
                self.assertEqual(
                    connection.execute(
                        "SELECT jobs FROM spell_list WHERE spellid = ?", (identifier,)
                    ).fetchone()[0],
                    bytes(22),
                )
            self.assertEqual(
                connection.execute(
                    "SELECT COUNT(*) FROM abilities WHERE abilityId IN (668,669,671) AND level = 255"
                ).fetchone()[0],
                3,
            )
            for spell, level in ((57, 48), (46, 63), (48, 10)):
                self.assertEqual(
                    connection.execute(
                        "SELECT min_level FROM mob_spell_lists WHERE spell_list_id = 210 AND spell_id = ?",
                        (spell,),
                    ).fetchone()[0],
                    level,
                )

    def test_native_tp_snapshot_contract(self):
        state = (ROOT / "src/map/ai/states/petskill_state.cpp").read_text()
        entity = (ROOT / "src/map/entities/pet_entity.cpp").read_text()
        self.assertIn(
            "SKILLFLAG_NO_TP_COST  = 0x004", (ROOT / "src/map/mobskill.h").read_text()
        )
        self.assertRegex(
            state,
            r"if \(!m_PSkill->isTpFreeSkill\(\)\)\s*\{\s*m_spentTP\s*= m_PEntity->health.tp;\s*m_PEntity->health.tp = 0;",
        )
        self.assertTrue(
            "setTP(state.GetSpentTP())" in entity,
            "Pet execution must use the state TP snapshot.",
        )

    def test_summoner_animation_mappings(self):
        skills = {
            row["pet_skill_id"]: row
            for row in rows("pet_skills")
            if row["mob_skill_id"] == 0 and row["pet_skill_flag"] & 192
        }
        self.assertTrue(skills)
        for identifier, skill in skills.items():
            self.assertEqual(skill["mob_skill_id"], 0, identifier)
            self.assertEqual(skill["pet_skill_finish_category"], 13, identifier)
            self.assertGreater(skill["pet_anim_time"], 0, identifier)
            self.assertLess(skill["pet_anim_id"], 4096, identifier)

        for identifier, animation in ((553, 41), (569, 57), (618, 106)):
            self.assertEqual(skills[identifier]["pet_anim_id"], animation)
            self.assertEqual(skills[identifier]["pet_anim_time"], 2000)

    def test_legacy_handler_coverage(self):
        code = (MODULE / "blood_pacts.lua").read_text()
        abilities = {
            row["name"]: row
            for row in rows("abilities")
            if row["job"] == 15 and row["level"] <= 75
        }
        for name in abilities:
            path = ROOT / f"scripts/actions/abilities/pets/{name}.lua"
            if path.exists() and "xi.summon.avatarPhysicalMove(" in path.read_text():
                self.assertRegex(code, rf"\b{name}\b")

    def test_level_up_announcements(self):
        source = (ROOT / "modules/sanctum/new_systems/level_up.lua").read_text()
        smn = source.split("[xi.job.SMN] =", 1)[1].split("[xi.job.BLU] =", 1)[0]
        for name in ("Apogee", "Deconstruction", "Chronoshift"):
            self.assertNotIn(name, smn)
        for level, name in (
            (55, "Inferno Howl"),
            (60, "Crystal Blessing"),
            (65, "Earthen Armor"),
        ):
            self.assertRegex(smn, rf"\[{level}\] = \{{[^\n]+{name}")

    def test_lua_behaviors(self):
        library = lua_library()
        state = library.luaL_newstate()
        library.luaL_openlibs(state)
        try:
            for path in [*MODULE.glob("*.lua"), Path(__file__).with_suffix(".lua")]:
                data = path.read_bytes()
                status = library.luaL_loadbuffer(
                    state, data, len(data), str(path).encode()
                )
                if status:
                    self.fail(library.lua_tolstring(state, -1, None).decode())
                library.lua_settop(state, 0)

            with database() as connection:
                connection.executescript((MODULE / "summoner.sql").read_text())
                flags = dict(
                    connection.execute(
                        "SELECT pet_skill_id, pet_skill_flag FROM pet_skills"
                    )
                )
            prelude = "ROOT = " + json.dumps(ROOT.as_posix() + "/") + "\n"
            prelude += (
                "petFlags = {"
                + ",".join(f"[{key}]={value}" for key, value in flags.items())
                + "}\n"
            )
            paths = sorted((ROOT / "scripts/actions/abilities/pets").glob("*.lua"))
            prelude += (
                "petFiles = {"
                + ",".join(
                    json.dumps(str(path.relative_to(ROOT)).replace("\\", "/"))
                    for path in paths
                )
                + "}\n"
            )
            code = (prelude + Path(__file__).with_suffix(".lua").read_text()).encode()
            status = library.luaL_loadbuffer(
                state, code, len(code), b"@summoner_regressions"
            )
            if not status:
                status = library.lua_pcall(state, 0, 0, 0)
            if status:
                error = library.lua_tolstring(state, -1, None).decode()
                library.lua_getfield(state, -10002, b"testOutput")
                output = library.lua_tolstring(state, -1, None)
                self.fail(error + "\n" + (output.decode() if output else ""))
            library.lua_getfield(state, -10002, b"testOutput")
            print(library.lua_tolstring(state, -1, None).decode())
        finally:
            library.lua_close(state)


if __name__ == "__main__":
    unittest.main(verbosity=2)
