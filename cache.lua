local CACHE_KEYS = {
  KEYAUTH_REFERER_CREDENTIAL = "keyauth_referer_credentials"
}

local _M = {}

function _M.keyauth_referer_credential_key(key)
  return CACHE_KEYS.KEYAUTH_REFERER_CREDENTIAL .. ":" .. key
end

return _M