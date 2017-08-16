return {
  {
    name = "2017-05-30_init_keyauthreferer",
    up = [[
      CREATE TABLE IF NOT EXISTS keyauthreferer_credentials(
        id uuid,
        consumer_id uuid REFERENCES consumers (id) ON DELETE CASCADE,
        key text UNIQUE,
        authorized_referer text,
        created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
        PRIMARY KEY (id)
      );

      DO $$
      BEGIN
        IF (SELECT to_regclass('keyauthreferer_key_idx')) IS NULL THEN
          CREATE INDEX keyauthreferer_key_idx ON keyauthreferer_credentials(key);
        END IF;
        IF (SELECT to_regclass('keyauthreferer_consumer_idx')) IS NULL THEN
          CREATE INDEX keyauthreferer_consumer_idx ON keyauthreferer_credentials(consumer_id);
        END IF;
      END$$;
    ]],
    down = [[
      DROP TABLE keyauthreferer_credentials;
    ]]
  }
}
