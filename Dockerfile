FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    curl ca-certificates nginx nginx-extras

# Adds lua_package_path and disable cache
RUN sed -z 's|http {\n|http {\n\tlua_package_path  "/etc/nginx/lua/?.lua;;";\
\n\tlua_code_cache off;\n|' -i /etc/nginx/nginx.conf

# Set new log file location
RUN sed -e 's|server {|server {\n    error_log /app/error.log;\n|' -i /etc/nginx/sites-enabled/default;

# Disable ipv6
RUN sed -e 's|listen \[::\]:80|# listen \[::\]:80|' -i /etc/nginx/sites-enabled/default;

# Configure route
RUN sed -z 's|location \/ {.*|location \/ {\n\
        access_by_lua_block {\n\
            ngx.header.content_type = "text/plain"\n\
        }\n\
        content_by_lua_file "\/app\/runtime.lua";\n\
    }\n\
}|' -i /etc/nginx/sites-enabled/default;

# Prepare environment to receive the lib
RUN mkdir -p /etc/nginx/lua && \
    bash -c "curl https://raw.githubusercontent.com/rxi/json.lua/master/json.lua > /etc/nginx/lua/json.lua"

WORKDIR /app

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
