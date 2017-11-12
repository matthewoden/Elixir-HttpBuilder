defmodule HttpBuilder.Adapter do
    
    alias HttpBuilder.HttpRequest
    @moduledoc """
    The HttpBuilder Adapter takes a Http.Request apart, and calls a method from the 
    result.
    """
    
    @type body :: term
    @callback send(HttpRequest.t) :: {:ok, body } | { :error, String.t }
    
end