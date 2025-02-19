import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/server_component

pub fn app() -> lustre.App(Model, Model, Msg) {
  lustre.component(init, update, view, dict.new())
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
    html.slot([
      attribute.name("client-input"),
      on_pong(UserSentPong),
      server_component.include(["detail"]),
    ]),
    html.h1([], [element.text("ping!")]),
    html.button([event.on_click(UserSentPong("Server Gen"))], [
      html.text("Send pong"),
    ]),
    html.div(
      [],
      list.map(model.pings, fn(ping) { html.li([], [element.text(ping)]) }),
    ),
  ])
}

pub fn encode_ping(ping: String) {
  json.object([#("ping", json.string(ping))])
}

pub fn on_pong(msg) {
  use event <- event.on("pong")

  io.debug(event)

  // msg("New pong!") |> Ok
  let decoder = {
    use pong <- decode.field("detail", decode.string)

    decode.success(pong)
  }

  let empty_error = [dynamic.DecodeError("", "", [])]

  use pong <- result.try(
    decode.run(event, decoder)
    |> result.replace_error(empty_error),
  )

  msg(pong)
  |> Ok
}
