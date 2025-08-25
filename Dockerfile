# See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

# Base image for runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081
EXPOSE 8085  

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["FantasyWebApp/FantasyWebApp.csproj", "FantasyWebApp/"]
RUN dotnet restore "./FantasyWebApp/FantasyWebApp.csproj"
COPY . .
WORKDIR "/src/FantasyWebApp"
RUN dotnet build "./FantasyWebApp.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./FantasyWebApp.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false
# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FantasyWebApp.dll"]
