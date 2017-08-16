return {
  {
    name = "2017-05-30_init_keyauthreferer",
    up =  [[
      CREATE TABLE IF NOT EXISTS keyauthreferer_credentials(
        id uuid,
        consumer_id uuid,
        key text,
        authorized_referer text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON keyauthreferer_credentials(key);
      CREATE INDEX IF NOT EXISTS keyauthreferer_consumer_id ON keyauthreferer_credentials(consumer_id);
    ]],
    down = [[
      DROP TABLE keyauthreferer_credentials;
    ]]
  }
}
