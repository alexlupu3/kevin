[Unit]
Description={{PROJECT}} Node API
After=network.target postgresql.service
Wants=network.target

[Service]
Type=simple
User={{API_USER}}
Group=www-data
WorkingDirectory={{APP_DIR}}
EnvironmentFile={{ENV_FILE}}
ExecStart={{NODE_COMMAND}} {{ENTRYPOINT}}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
