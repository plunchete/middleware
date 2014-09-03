local spec  = require 'spec.spec'
local cjson = require 'cjson'

describe("citybike_distance", function()

  it("adds a distance attribute to all the elements in the received json array, using their lat and long. Also, sorts by distance", function()

    local input_json = cjson.encode({
      stationBeanList = {
        {name="Hipster Men Clothes",  latitude=37.761353, longitude = -122.4298161},
        {name="Fancy Coffee Shop", latitude=37.760288, longitude = -122.504993 },
        {name="Apple Store",  latitude=37.785991, longitude = -122.406470 }
      }
    })

    local citibike_distance = spec.middleware('citybikeAPI-distance/citybike_location.lua')
    local request           = spec.request({method = 'GET', uri = '/'})
    local next_middleware = spec.next_middleware(function()
      assert.contains(request, { method = 'GET', uri = '/' })
      return {status = 200, body = input_json}
    end)

    local response = citibike_distance(request, next_middleware)

    assert.spy(next_middleware).was_called()

    assert.contains(response, {status = 200 })

    assert.same(cjson.decode(response.body), {
      {name="Apple Store",  latitude=37.785991, longitude = -122.406470, distance = 0.13467403418529 },
      {name="Hipster Men Clothes",  latitude=37.761353, longitude = -122.4298161, distance = 2.1491348395457},
      {name="Fancy Coffee Shop", latitude=37.760288, longitude = -122.504993, distance = 5.605989319191 }
    })
  end)
end)


