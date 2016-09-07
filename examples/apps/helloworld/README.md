# Amalgam8 helloworld sample

## Overview

The helloworld sample starts two versions of a helloworld microservice, to demonstrate how Amalgam8 can be used to split 
incoming traffic between the two versions. You can define the proportion of traffic to each microservice as a percentage.

## Running the helloworld demo

Before you begin, follow the environment set up instructions at https://github.com/amalgam8/examples/blob/master/README.md

1. Confirm that the microservices are running, by running the following command:

    ```bash
    a8ctl service-list
    ```
    
    The expected output is the following:
    
    ```
    +------------+--------------+
    | Service    | Instances    |
    +------------+--------------+
    | helloworld | v1(2), v2(2) |
    +------------+--------------+
    ```

    There are 4 instances of the helloworld service. 2 are instances of version "v1" and 2 are version "v2". 

1. Send all traffic to the v1 version of helloworld, by running the following command:

    ```
    a8ctl route-set helloworld --default v1
    ```

1. You can confirm the routes are set by running the following command:

    ```bash
    a8ctl route-list
    ```

    You should see the following output:

    ```
    +------------+-----------------+-------------------+
    | Service    | Default Version | Version Selectors |
    +------------+-----------------+-------------------+
    | helloworld | v1              |                   |
    +------------+-----------------+-------------------+
    ```

1. Confirm that all traffic is being directed to the v1 instance, by running the following cURL command multiple times:

    ```
    curl http://localhost:32000/helloworld/hello
    ```

    **Note**: Replace GATEWAY_URL above with the appropriate URL of the gateway
    for your environment (for example, http://localhost:32000, http://192.168.33.33:32000, etc.).

    You can see that the traffic is continually routed between the v1 instances only, in a round-robin fashion:

    ```
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-p8909
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-qwpex
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-p8909
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-qwpex
    ...
    ```

1. Next, we will split traffic between helloworld v1 and v2

    Run the following command to send 25% of the traffic to helloworld v2, leaving the rest (75%) on v1:
    
    ```
    a8ctl route-set helloworld --default v1 --selector 'v2(weight=0.25)'
    ```

1. Run this cURL command several times:

    ```
    curl http://localhost:32000/helloworld/hello
    ```

    You will see alternating responses from all 4 helloworld instances, where approximately 1 out of every 4 (25%) responses
    will be from a "v2" instances, and the other responses from the "v1" instances:

    ```
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-p8909
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-qwpex
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v2, container: helloworld-v2-ggkvd
    $ curl http://localhost:32000/helloworld/hello
    Hello version: v1, container: helloworld-v1-p8909
    ...
    ```

    Note: if you use a browser instead of cURL to access the service and continually refresh the page, 
    it will always return the same version (v1 or v2), because a cookie is set to maintain version affinity.
    However, the browser still round-robins between the specific version instances that it returns.

## Using the Amalgam8 REST API

You can look at registration details for a service in the A8 registry, by running the following cURL command:

```
curl -X GET http://localhost:31300/api/v1/services/helloworld | jq .
```

**Note**: Replace localhost:31300 above with the appropriate host
for your environment (for example, "a8-registry.mybluemix.net", etc.).

The output should look something like this:

```
{
  "instances": [
    {
      "tags": [
        "v2"
      ],
      "last_heartbeat": "2016-08-31T21:27:02.059242566Z",
      "status": "UP",
      "ttl": 60,
      "endpoint": {
        "value": "172.17.0.8:5000",
        "type": "http"
      },
      "service_name": "helloworld",
      "id": "d57b8e5150a2d1cd"
    },
    {
      "tags": [
        "v1"
      ],
      "last_heartbeat": "2016-08-31T21:27:02.142425226Z",
      "status": "UP",
      "ttl": 60,
      "endpoint": {
        "value": "172.17.0.9:5000",
        "type": "http"
      },
      "service_name": "helloworld",
      "id": "6e274c9ac7312f6d"
    },
    {
      "tags": [
        "v1"
      ],
      "last_heartbeat": "2016-08-31T21:27:02.421942924Z",
      "status": "UP",
      "ttl": 60,
      "endpoint": {
        "value": "172.17.0.14:5000",
        "type": "http"
      },
      "service_name": "helloworld",
      "id": "d9c42f2ce7cae5ff"
    },
    {
      "tags": [
        "v2"
      ],
      "last_heartbeat": "2016-08-31T21:27:02.921321593Z",
      "status": "UP",
      "ttl": 60,
      "endpoint": {
        "value": "172.17.0.15:5000",
        "type": "http"
      },
      "service_name": "helloworld",
      "id": "1061aca7b335fb94"
    }
  ],
  "service_name": "helloworld"
}
```

To list the routes for a service, run the following cURL command:

```
curl http://localhost:31200/v1/rules/routes/helloworld | jq .
```

**Note**: Replace localhost:31200 above with the appropriate host
for your environment (for example, "a8-controller.mybluemix.net", etc.).

After running the demo, the output should be as follows:

```
{
  "rules": [
    {
      "route": {
        "backends": [
          {
            "tags": [
              "v2"
            ],
            "weight": 0.25
          },
          {
            "tags": [
              "v1"
            ]
          }
        ]
      },
      "destination": "helloworld",
      "priority": 1,
      "id": "3ee8fcaf-929e-40bc-8eb3-a7f4e4ffdf96"
    }
  ]
}
```

You can also set routes using the REST API. For example, to send all traffic to v2, run the following curl command:

```
curl -X PUT http://localhost:31200/v1/rules/routes/helloworld -d '{"rules": [{"priority": 1, "route": {"backends": [{"tags": ["v2"]}]}, "destination": "helloworld"}]}' -H "Content-Type: application/json"
```
