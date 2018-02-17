# Key authentification and referer

Add Key Authentication (also referred to as an API key) and referer validation to your APIs. Consumers then add their key either in a querystring parameter or a header to authenticate their requests.

----

## Installation (for >= v2.x)

Install the rock when building your Kong image/instance:
```
luarocks install kong-plugin-key-auth-referer
```

Add the plugin to your `custom_plugins` section in `kong.conf`, the `KONG_CUSTOM_PLUGINS` is also available.

```
custom_plugins = key-auth-referer
```

----

## Compatibility

| Plugin  | Kong version |
|--|--|
| v1.0 | 0.10.x |
| v2.0 | 0.12.x |

----

## Terminology

- `api`: your upstream service placed behind Kong, for which Kong proxies requests to.
- `plugin`: a plugin executing actions inside Kong before or after a request has been proxied to the upstream API.
- `consumer`: a developer or service using the api. When using Kong, a Consumer only communicates with Kong which proxies every call to the said, upstream api.
- `credential`: in the key-auth-referer plugin context, a unique string associated with a consumer, also referred to as an API key.

----

## Configuration

Configuring the plugin is straightforward, you can add it on top of an [API][api-object] by executing the following request on your Kong server:


```bash
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=key-auth-referer" \
    --data "config.hide_credentials=true"
```

`api`: The `id` or `name` of the API that this plugin configuration will target

You can also apply it for every API using the `http://kong:8001/plugins/` endpoint. Read the [Plugin Reference](https://getkong.org/docs/latest/admin-api/#add-plugin) for more information.

Once applied, any user with a valid credential can access the service/API.
To restrict usage to only some of the authenticated users, also add the
[ACL](https://getkong.org/plugins/acl/) plugin (not covered here) and create whitelist or
blacklist groups of users.

form parameter                   | default | description
---                              | ---     | ---               
`name`                           |         | The name of the plugin to use, in this case: `key-auth-referer`.
`config.key_names`<br>*optional* | `apikey`| Describes an array of comma separated parameter names where the plugin will look for a key. The client must send the authentication key in one of those key names, and the plugin will try to read the credential from a header or the querystring parameter with the same name.<br>*note*: the key names may only contain [a-z], [A-Z], [0-9] and [-].
`config.key_in_body`             | `false` | If enabled, the plugin will read the request body (if said request has one and its MIME type is supported) and try to find the key in it. Supported MIME types are `application/www-form-urlencoded`, `application/json`, and `multipart/form-data`.
`config.hide_credentials`<br>*optional* | `false` | An optional boolean value telling the plugin to hide the credential to the upstream API server. It will be removed by Kong before proxying the request.
`config.anonymous`<br>*optional*           | `` | An optional string (consumer uuid) value to use as an "anonymous" consumer if authentication fails. If empty (default), the request will fail with an authentication failure `4xx`

----

## Usage

In order to use the plugin, you first need to create a Consumer to associate one or more credentials to. The Consumer represents a developer using the final service/API.

### Create a Consumer

You need to associate a credential to an existing [Consumer][consumer-object] object, that represents a user consuming the API. To create a [Consumer][consumer-object] you can execute the following request:

```bash
$ curl -X POST http://kong:8001/consumers/ \
    --data "username=<USERNAME>" \
    --data "custom_id=<CUSTOM_ID>"
HTTP/1.1 201 Created

{
    "username":"<USERNAME>",
    "custom_id": "<CUSTOM_ID>",
    "created_at": 1472604384000,
    "id": "7f853474-7b70-439d-ad59-2481a0a9a904"
}
```

parameter                      | default | description
---                            | ---     | ---
`username`<br>*semi-optional*  |         | The username of the Consumer. Either this field or `custom_id` must be specified.
`custom_id`<br>*semi-optional* |         | A custom identifier used to map the Consumer to another database. Either this field or `username` must be specified.

A [Consumer][consumer-object] can have many credentials.

If you are also using the [ACL](https://getkong.org/plugins/acl/) plugin and whitelists with this
service, you must add the new consumer to a whitelisted group. See
[ACL: Associating Consumers][acl-associating] for details.

### Create an API Key

You can provision new credentials by making the following HTTP request:

```bash
$ curl -X POST http://kong:8001/consumers/{consumer}/key-auth-referer \
    --data "authorized_referer=*"

HTTP/1.1 201 Created

{
    "authorized_referer":["*"],
    "consumer_id":"2e2729d3-b58f-4980-a283-06302990f91b",
    "id":"1014ecc5-c7e4-4e4c-8800-868a15aea0f3",
    "key":"38f6b9c30560474e9998289928d86476",
    "created_at":1496150875000
}
```

`consumer`: The `id` or `username` property of the [Consumer][consumer-object] entity to associate the credentials to.

form parameter      | default | description
---                 | ---     | ---
`key`<br>*optional* |         | You can optionally set your own unique `key` to authenticate the client. If missing, the plugin will generate one.
`authorized_referer` |         | List of authorized referer (see [test-referer.lua](/kong/plugins/key-auth-referer/test-referer.lua))

<div class="alert alert-warning">
  <strong>Note:</strong> It is recommended to let Kong auto-generate the key. Only specify it yourself if you are migrating an existing system to Kong. You must re-use your keys to make the migration to Kong transparent to your Consumers.
</div>

### Using the API Key

Simply make a request with the key as a querystring parameter:

```bash
$ curl http://kong:8000/{api path}?apikey=<some_key>
```

Or in a header:

```bash
$ curl http://kong:8000/{api path} \
    -H 'apikey: <some_key>'
```

### Upstream Headers

When a client has been authenticated, the plugin will append some headers to the request before proxying it to the upstream API/Microservice, so that you can identify the Consumer in your code:

* `X-Consumer-ID`, the ID of the Consumer on Kong
* `X-Consumer-Custom-ID`, the `custom_id` of the Consumer (if set)
* `X-Consumer-Username`, the `username` of the Consumer (if set)
* `X-Credential-Username`, the `username` of the Credential (only if the consumer is not the 'anonymous' consumer)
* `X-Anonymous-Consumer`, will be set to `true` when authentication failed, and the 'anonymous' consumer was set instead.

You can use this information on your side to implement additional logic. You can use the `X-Consumer-ID` value to query the Kong Admin API and retrieve more information about the Consumer.

[api-object]: https://getkong.org/docs/latest/admin-api/#api-object
[configuration]: https://getkong.org/docs/latest/configuration
[consumer-object]: https://getkong.org/docs/latest/admin-api/#consumer-object
[acl-associating]: https://getkong.org/plugins/acl/#associating-consumers
[faq-authentication]: https://getkong.org/about/faq/#how-can-i-add-authentication-to-a-microservice-api