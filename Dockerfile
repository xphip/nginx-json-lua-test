FROM nginx:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    curl ca-certificates nginx-extras

# Adds lua_package_path and disable cache
RUN sed -z 's|http {\n|http {\n\tlua_package_path  "/etc/nginx/lua/?.lua;;";\
\n\tlua_code_cache off;\n|' -i /etc/nginx/nginx.conf

# Configure route
RUN sed -z 's|location \/ {.*htm;|location \/ { \
        access_by_lua_block { \
            ngx.header.content_type = "text/plain" \
        } \
        content_by_lua_file "\/app\/runtime.lua";|' -i /etc/nginx/conf.d/default.conf;

# Prepare environment to receive the lib
RUN mkdir -p /etc/nginx/lua && \
    bash -c "curl https://raw.githubusercontent.com/rxi/json.lua/master/json.lua > /etc/nginx/lua/json.lua"

WORKDIR /app


