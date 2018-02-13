local function testReferer(refererConf, refererToTest)
  if refererConf == refererToTest then
    return true
  end
  
  local authorizedReferer = string.gsub(refererConf, "%.", "%%.")
  authorizedReferer = string.gsub(authorizedReferer, "*", "[^.]*")

  local test = string.match(refererToTest, authorizedReferer)
  if test == refererToTest then
    return true
  else
    return false
  end
end


local function testListReferer(listReferer, refererToTest)
  if refererToTest == "" or refererToTest == nil then
    return false
  end

  local domainRefererToTest = string.match(refererToTest, "^[https?]*[://]*([^/]+)")
  
  if domainRefererToTest == nil then
    return false
  end



  for index, valeur in ipairs(listReferer) do
    if valeur == "*" then
      return true
    end

    if testReferer(valeur, domainRefererToTest) == true then
      return true
    end
  end

  return false
end

print("1", testListReferer({"example", }, "http://example/plan"), "true")

print("1", testListReferer({"example.com", }, "http://example.com/lolll"), "true")
print("2", testListReferer({"www.example.com"}, "http://www.example.com"), "true")
print("3", testListReferer({"www.example.com"}, "http://ws.example.com"), "false")
print("4", testListReferer({"*"}, "http://ws.example.com"), "true")
print("5", testListReferer({"*.example.com"}, "http://ws.example.com"), "true")
print("6", testListReferer({"*.example.com"}, "http://example.com"), "false")
print("7", testListReferer({"*.example.com"}, "http://a.b.example.com"), "false")
print("8", testListReferer({"*.example.com"},   "http://a.example.com.evil.com"), "false")
print("9", testListReferer({"a.*.example.com"}, "http://a.bc.example.com"), "true")
print("10", testListReferer({"a.*.example.com"}, "http://b.bc.example.com"), "false")
print("11", testListReferer({"example.com"}, "http://exampleXcom"), "false")