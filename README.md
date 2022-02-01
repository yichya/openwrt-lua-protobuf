# lua-protobuf

[https://github.com/starwing/lua-protobuf](https://github.com/starwing/lua-protobuf) for OpenWrt

## protoc.lua

A protobuf to pb binary format compiler implemented in pure lua.

```lua
#!/usr/bin/lua

local protoc = require "protoc"
local p = protoc.new()
local pc = p:compile([[
syntax = "proto3";
// Domain for routing decision.
message Domain {
  // Type of domain value.
  enum Type {
    // The value is used as is.
    Plain = 0;
    // The value is used as a regular expression.
    Regex = 1;
    // The value is a root domain.
    Domain = 2;
    // The value is a domain.
    Full = 3;
  }

  // Domain matching type.
  Type type = 1;

  // Domain value.
  string value = 2;

  message Attribute {
    string key = 1;

    oneof typed_value {
      bool bool_value = 2;
      int64 int_value = 3;
    }
  }

  // Attributes of this domain. May be used for filtering.
  repeated Attribute attribute = 3;
}

// IP for routing decision, in CIDR form.
message CIDR {
  // IP address, should be either 4 or 16 bytes.
  bytes ip = 1;

  // Number of leading ones in the network mask.
  uint32 prefix = 2;
}

message GeoIP {
  string country_code = 1;
  repeated CIDR cidr = 2;
  bool reverse_match = 3;
}

message GeoIPList {
  repeated GeoIP entry = 1;
}

message GeoSite {
  string country_code = 1;
  repeated Domain domain = 2;
}

message GeoSiteList {
  repeated GeoSite entry = 1;
}
]])

local function write_file(path, bytes)
    local file = io.open(path, "wb")
    if not file then return nil end
    file:write(bytes)
    file:close()
end

write_file("geoip.pb", pc)
```

## pb.so

Actual serialize & deserialize library

```lua
#!/usr/bin/lua

local pb = require "pb"

local function read_file(path)
    local file = io.open(path, "rb")
    if not file then 
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

if arg[1] == nil then
    do
        return
    end
end

pb.load(read_file("geoip.pb"))

local data = assert(pb.decode("GeoIPList", read_file("/usr/share/xray/geoip.dat")))

for _, x in ipairs(data.entry) do
    if x.country_code == arg[1] then
        for _, y in ipairs(x.cidr) do
            if string.byte(y.ip, 16) == nil then
                local b0 = string.byte(y.ip, 1) or 0
                local b1 = string.byte(y.ip, 2) or 0
                local b2 = string.byte(y.ip, 3) or 0
                local b3 = string.byte(y.ip, 4) or 0
                print(string.format("%d.%d.%d.%d/%d", b0, b1, b2, b3, y.prefix))
            end
        end
    end
end
```
