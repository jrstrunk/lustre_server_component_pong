import client_pong
import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/result
import lustre

pub const name = "pong-client"

pub fn main() {
  io.debug("Starting client")

  let app =
    lustre.component(
      client_pong.init,
      client_pong.update,
      client_pong.view,
      dict.from_list([
        #("server-pongs", fn(dy) {
          dynamic.string(dy)
          |> result.map(client_pong.ServerSentPing)
        }),
      ]),
    )

  let assert Ok(Nil) = lustre.register(app, "pong-client")

  Nil
}
