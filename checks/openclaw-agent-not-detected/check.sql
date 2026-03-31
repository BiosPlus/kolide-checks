SELECT
  CASE
    WHEN COUNT(*) > 0 THEN 'FAIL'
    ELSE 'PASS'
  END AS KOLIDE_CHECK_STATUS,
  CASE
    WHEN COUNT(*) > 0 THEN 'OpenClaw agent artifacts detected: ' || GROUP_CONCAT(source, ', ')
    ELSE 'No OpenClaw artifacts detected'
  END AS details
FROM (
  -- Check for OpenClaw.app
  SELECT '/Applications/OpenClaw.app' AS path, 'app' AS source
  FROM file
  WHERE path = '/Applications/OpenClaw.app'

  UNION ALL

  -- Check for ~/.openclaw directory
  SELECT file.path, 'config_dir' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path = users.directory || '/.openclaw'
    AND file.type = 'directory'

  UNION ALL

  -- Check for ~/.openclaw-<profile> directories
  SELECT file.path, 'profile_dir' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path LIKE users.directory || '/.openclaw-%'
    AND file.type = 'directory'

  UNION ALL

  -- Check for bot.molt.gateway.plist (current naming)
  SELECT file.path, 'launchagent_current' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path = users.directory || '/Library/LaunchAgents/bot.molt.gateway.plist'

  UNION ALL

  -- Check for bot.molt.*.plist (profile-based installs)
  SELECT file.path, 'launchagent_profile' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path LIKE users.directory || '/Library/LaunchAgents/bot.molt.%.plist'
    AND file.path != users.directory || '/Library/LaunchAgents/bot.molt.gateway.plist'

  UNION ALL

  -- Check for com.openclaw.* legacy plists
  SELECT file.path, 'launchagent_legacy' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path LIKE users.directory || '/Library/LaunchAgents/com.openclaw.%'

  UNION ALL

  -- Check for running openclaw processes
  SELECT path, 'running_process' AS source
  FROM processes
  WHERE name = 'openclaw'
     OR name = 'node' AND cmdline LIKE '%openclaw%'

  UNION ALL

  -- Check for openclaw binary in common global npm paths
  SELECT path, 'binary' AS source
  FROM file
  WHERE path IN (
    '/usr/local/bin/openclaw',
    '/opt/homebrew/bin/openclaw'
  )

  UNION ALL

  -- Check for openclaw in user npm global bin
  SELECT file.path, 'binary_user' AS source
  FROM users
  CROSS JOIN file
  WHERE file.path = users.directory || '/.npm-global/bin/openclaw'
     OR file.path = users.directory || '/.local/bin/openclaw'
     OR file.path = users.directory || '/.bun/bin/openclaw'
);