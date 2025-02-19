import gleam/dict
import gleam/io
import gleam/json
import gleam/list
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/server_component

pub fn app() -> lustre.App(Model, Model, Msg) {
  lustre.component(
    init,
    update,
    view,
    [
      #("data", pong_decoder),
      #("pong", pong_decoder),
      #("data-pong", pong_decoder),
    ]
      |> dict.from_list,
  )
}

pub type Model {
  Model(pings: List(String))
}

pub fn init(flag) -> #(Model, Effect(Msg)) {
  #(flag, effect.none())
}

pub type Msg {
  UserSentPong(String)
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserSentPong(ping) -> #(
      Model(pings: [ping, ..model.pings]),
      server_component.emit("ping", encode_ping(ping)),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.h1([], [element.text("ping!")]),
    html.div(
      [on_pong(UserSentPong)],
      list.map(model.pings, fn(ping) { html.li([], [element.text(ping)]) }),
    ),
  ])
}

pub fn encode_ping(ping: String) {
  json.object([#("ping", json.string(ping))])
}

pub fn pong_decoder(_) {
  // use pong <- decode.subfield(["data", "pong"], decode.string)
  // decode.success()
  io.debug("decoding spong!")
  Ok(UserSentPong("New pong data!"))
}

pub fn on_pong(msg) {
  use event <- event.on("pong")

  io.debug("pong!")
  io.debug(event)

  msg("New pong!") |> Ok
  // let decoder = {
  //   use pong <- decode.subfield(["data", "pong"], decode.string)

  //   decode.success(pong)
  // }

  // let empty_error = [dynamic.DecodeError("", "", [])]

  // use pong <- result.try(
  //   decode.run(event, decoder)
  //   |> result.replace_error(empty_error),
  // )

  // msg(pong)
  // |> Ok
}
