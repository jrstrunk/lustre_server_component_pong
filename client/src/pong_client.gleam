import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/result
import lustre
import pong/shared

pub const name = "pong-client"

pub fn main() {
  io.debug("Starting client")

  let app =
    lustre.component(
      shared.init,
      shared.update,
      shared.view,
      dict.from_list([
        #("server-pongs", fn(dy) {
          dynamic.string(dy)
          |> result.map(shared.ServerSentPing)
        }),
      ]),
    )

  let assert Ok(Nil) = lustre.register(app, "pong-client")

  Nil
}
