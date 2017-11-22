defmodule HttpBuilder.HttpRequest do
    @moduledoc """
    Provides a struct, containing all the options for a potential HTTP Request.
    """

    defstruct [ adapter: nil, body: nil, headers: [], host: "", path: "", 
                method: nil,  query_params: [], rec_timeout: 5000, 
                req_timeout: 8000, options: []  ]

    @type t :: %__MODULE__{
        adapter: atom,       
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