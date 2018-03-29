defmodule HttpBuilder.HttpRequest do
    @moduledoc """
    Provides a struct, containing all the options for a potential HTTP Request.
    """

    @default_parser if Code.ensure_loaded?(Poison), do: HttpBuilder.Adapters.JSONParser.Poison, else: nil

    defstruct [ adapter: nil, body: nil, headers: [], json_parser: @default_parser, host: "", path: "", 
                method: nil,  query_params: [], rec_timeout: 5000, 
                req_timeout: 8000, options: []  ]

    @type t :: %__MODULE__{
        adapter: atom,    
        json_parser: module,   
        body: map,       
        headers: list, 
        host: String.t,   
        path: String.t,      
        method: atom | nil,
        query_params: list,
        rec_timeout: integer,
        req_timeout: integer,        
        options: list
    }
end