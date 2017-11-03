defmodule WORKER do
    
      def encryptInput(k,i,ser_PID) do
        #random = Base.encode64(:crypto.strong_rand_bytes(6)) |> binary_part(0, 6)
        random = get_string(8)
        input="divyarengs;"<>random<>Integer.to_string(i)
        hashed = Base.encode16(:crypto.hash(:sha256, input))
        kZeros = String.duplicate("0",k)
    
        if String.slice(hashed, 0..k-1)==kZeros do
          #if String.equivalent?(String.slice(hashed, k..k),"0")==false do 
              #IO.puts input<>"\t"<>hashed
              send ser_PID, { :response, input<>"\t"<>hashed}
          #end
        end    
        encryptInput(k,i+1, ser_PID)
      end
    
    def encryptInputClient(k,i, str, socket) do
        random = Base.encode64(:crypto.strong_rand_bytes(6)) |> binary_part(0, 6)
        input="divyarengs;"<>random<>Integer.to_string(i)
        hashed = Base.encode16(:crypto.hash(:sha256, input))
        
        kZeros = String.duplicate("0",k)
        
        if String.slice(hashed, 0..k-1) == kZeros do
            #if String.equivalent?(String.slice(hashed, k..k),"0")==false do
            IO.puts "Success!"
            :gen_tcp.send(socket, Enum.join([input,hashed], "\t"))
            #end
        end
        encryptInputClient( k, i+1 , str, socket)
    end




    def seed_random do
        use_monotonic = :erlang.module_info 
            |> Keyword.get( :exports ) 
            |> Keyword.get( :monotonic_time )
        time_bif = case use_monotonic do
          1   -> &:erlang.monotonic_time/0
          nil -> &:erlang.now/0
        end
        :random.seed( time_bif.() )
    end

    def string( length ) do
        get_string( length )
    end

    def string() do
        get_string( 8 )
    end

    def get_string( length ) do
        seed_random
        alphabet
            =  "abcdefghijklmnopqrstuvwxyz"
            <> "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            <> "0123456789"
        alphabet_length = 
        
        alphabet |> String.length

        1..length
          |> Enum.map_join( 
            fn(_) ->
              alphabet |> String.at( :random.uniform( alphabet_length ) - 1 )
            end
          )
    end

    def number() do
        get_number(8)
    end

    def number( length ) do
        get_number( length )
    end

    def get_number( length ) do
        seed_random

        { number, "" } = 
          Integer.parse 1..length 
          |> Enum.map_join( fn(_) ->  :random.uniform(10) - 1 end )
        
        number
    end



      
end