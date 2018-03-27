defmodule ElChat.Helper do
  def ensure_hash(hash, text) do
    (:crypto.hmac(:sha256, 'secret', text) |> Base.encode64) == hash
  end
end