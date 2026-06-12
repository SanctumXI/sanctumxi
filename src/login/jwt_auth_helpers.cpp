/*
===========================================================================

  Copyright (c) 2023 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "jwt_auth_helpers.h"

#include "common/logging.h"
#include "common/settings.h"

#include <httplib.h>
#include <nlohmann/json.hpp>

namespace
{

std::string trimTrailingSlash(std::string value)
{
    while (!value.empty() && value.back() == '/')
    {
        value.pop_back();
    }
    return value;
}

} // namespace

JwtAuthResult validateSanctumJwt(const std::string& accessToken)
{
    JwtAuthResult result;

    if (accessToken.empty())
    {
        result.errorMessage = "Missing access token";
        return result;
    }

    const auto authHost = trimTrailingSlash(settings::get<std::string>("network.JWT_AUTH_HOST"));
    if (authHost.empty())
    {
        result.errorMessage = "JWT authentication is not configured on this server";
        return result;
    }

    httplib::Client cli(authHost);
    cli.set_connection_timeout(10, 0);
    cli.set_read_timeout(10, 0);

    httplib::Headers headers = {
        { "Authorization", fmt::format("Bearer {}", accessToken) },
        { "Accept", "application/json" },
    };

    const auto response = cli.Get("/api/auth/launcher/game-login", headers);
    if (!response)
    {
        result.errorMessage = fmt::format("Could not reach authentication server at {}", authHost);
        return result;
    }

    if (response->status == 401)
    {
        result.errorMessage = "Invalid or expired access token";
        return result;
    }

    if (response->status == 403)
    {
        result.errorMessage = "Authentication server requires HTTPS";
        return result;
    }

    if (response->status == 404)
    {
        result.errorMessage = "No game account linked to this Discord user";
        return result;
    }

    if (response->status != 200)
    {
        result.errorMessage = fmt::format("Authentication server rejected login (HTTP {})", response->status);
        return result;
    }

    const auto jsonBody = nlohmann::json::parse(response->body, nullptr, false);
    if (jsonBody.is_discarded() || !jsonBody.contains("accountId"))
    {
        result.errorMessage = "Authentication server returned an invalid response";
        return result;
    }

    result.success    = true;
    result.accountID  = jsonBody["accountId"].get<uint32>();
    result.login      = jsonBody.value("login", std::string{});
    return result;
}
