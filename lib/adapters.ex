defmodule HttpBuilder.Adapter do
    
    alias HttpBuilder.HttpRequest
    @moduledoc """
    The HttpBuilder Adapter takes a Http.Request, and converts it to an outgoing
    call.
    """
    
    @type result :: term

    @doc """
    Send is the only method required for this behaviour.
    
    It should take a response, initiate a request, and return a standard two 
    item tuple of {:ok, response } or {:error, reason }. It sets no expectations
    about the content of a successful response, to allow for more flexibility 
    in the result.

    See `HttpBuilder.Adapter.HTTPoison` for an example.
    """
    @callback send(HttpRequest.t) :: result
    
end

defmodule HttpBuilder.Adapter.JSONParser do
    
    @moduledoc """
    A JSON encoder/decoder interface for HttpBuilder adapters.
    """


    @type encoded :: term
    @type decoded :: nil | true | false | list | float | integer | String.t | map

    @doc """
    Takes a value, and encodes it into JSON
    """
    @callback encode!(value :: term, options :: Keyword.t) :: encoded
    
    @doc """
    Takes JSON, and decodes it to a value
    """
    @callback decode!(value :: term, options :: Keyword.t) :: decoded
    

end