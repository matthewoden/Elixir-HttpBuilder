if Code.ensure_loaded?(HTTPoison) do
    defmodule HttpBuilder.Adapters.HTTPosion do
        alias HttpBuilder.HttpRequest
        @moduledoc false
        @doc false
        @spec send(HttpRequest.t) :: HttpRequest.Adapter.result
        def send(request) do
            IO.warn "`HttpBuilder.Adapters.HTTPosion/1` is deprecated; call `HttpBuilder.Adapters.HTTPoison/2` instead. (note module typo)",
                Macro.Env.stacktrace(__ENV__)

            HttpBuilder.Adapters.HTTPoison.send(request)
        end
    end
end