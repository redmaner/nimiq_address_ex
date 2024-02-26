defmodule NimiqAddress.Base do
  import Bitwise

  @doc """
  encode32 encodes binary string to Base32 encoding using the Nimiq alphabet.
  """
  def encode32(bytes), do: encode_base32_nimiq(bytes, "", false)

  @nimiq_alphabet ~c{0123456789ABCDEFGHJKLMNPQRSTUVXY}

  to_encode_list = fn alphabet ->
    for e1 <- alphabet, e2 <- alphabet, do: bsl(e1, 8) + e2
  end

  encoded = to_encode_list.(@nimiq_alphabet)
  name = :encode_base32_nimiq

  # Code adapted from the official Base Elixir library.
  @compile {:inline, [{name, 1}]}
  defp unquote(name)(byte) do
    elem({unquote_splicing(encoded)}, byte)
  end

  defp unquote(name)(<<c1::10, c2::10, c3::10, c4::10, rest::binary>>, acc, pad?) do
    unquote(name)(
      rest,
      <<
        acc::binary,
        unquote(name)(c1)::16,
        unquote(name)(c2)::16,
        unquote(name)(c3)::16,
        unquote(name)(c4)::16
      >>,
      pad?
    )
  end

  defp unquote(name)(<<c1::10, c2::10, c3::10, c4::2>>, acc, pad?) do
    <<
      acc::binary,
      unquote(name)(c1)::16,
      unquote(name)(c2)::16,
      unquote(name)(c3)::16,
      c4 |> bsl(3) |> unquote(name)() |> band(0x00FF)::8
    >>
    |> maybe_pad(pad?, 1)
  end

  defp unquote(name)(<<c1::10, c2::10, c3::4>>, acc, pad?) do
    <<
      acc::binary,
      unquote(name)(c1)::16,
      unquote(name)(c2)::16,
      c3 |> bsl(1) |> unquote(name)() |> band(0x00FF)::8
    >>
    |> maybe_pad(pad?, 3)
  end

  defp unquote(name)(<<c1::10, c2::6>>, acc, pad?) do
    <<
      acc::binary,
      unquote(name)(c1)::16,
      c2 |> bsl(4) |> unquote(name)()::16
    >>
    |> maybe_pad(pad?, 4)
  end

  defp unquote(name)(<<c1::8>>, acc, pad?) do
    <<acc::binary, c1 |> bsl(2) |> unquote(name)()::16>>
    |> maybe_pad(pad?, 6)
  end

  defp unquote(name)(<<>>, acc, _pad?) do
    acc
  end

  defp maybe_pad(acc, false, _count), do: acc
end
