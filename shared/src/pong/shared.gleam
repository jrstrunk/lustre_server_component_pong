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

pub fn app() -> lustre.App(Model, Model, Msg) {
  lustre.component(init, update, view, dict.new())
}

pub type Model {
  Model(pongs: List(String), current_pong: String)
}

pub fn init(flag) -> #(Model, Effect(Msg)) {
  #(flag, effect.none())
}

pub type Msg {
  UserWrotePong(String)
  UserSentPong
  ServerSentPing(String)
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserWrotePong(pong) -> #(Model(..model, current_pong: pong), effect.none())
    UserSentPong -> #(
      Model(pongs: [model.current_pong, ..model.pongs], current_pong: ""),
      event.emit("pong", json.string(model.current_pong)),
    )
    ServerSentPing(ping) -> #(
      Model(..model, pongs: [ping, ..model.pongs]),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.h1([], [element.text("pong!")]),
    html.input([
      attribute.type_("text"),
      attribute.id("pong-input"),
      event.on_input(UserWrotePong),
      on_ctrl_enter(UserSentPong),
      attribute.value(model.current_pong),
    ]),
    html.button([attribute.id("pong-button"), event.on_click(UserSentPong)], [
      element.text("Send pong"),
    ]),
    html.ul(
      [],
      list.map(model.pongs, fn(pong) { html.li([], [element.text(pong)]) }),
    ),
  ])
}

pub fn on_ctrl_enter(msg: msg) {
  use event <- event.on("keydown")

  let decoder = {
    use ctrl_key <- decode.field("ctrlKey", decode.bool)
    use key <- decode.field("key", decode.string)

    decode.success(#(ctrl_key, key))
  }

  let empty_error = [dynamic.DecodeError("", "", [])]

  use #(ctrl_key, key) <- result.try(
    decode.run(event, decoder)
    |> result.replace_error(empty_error),
  )

  case ctrl_key, key {
    True, "Enter" -> Ok(msg)
    _, _ -> Error(empty_error)
  }
}

pub fn encode_model(model: Model) {
  json.array(model.pongs, json.string)
  |> json.to_string
}

pub fn decode_model(encoded_model: String) {
  let pongs =
    json.parse(encoded_model, decode.list(decode.string)) |> result.unwrap([])

  Model(pongs: pongs, current_pong: "")
}

pub fn on_ping(msg) {
  use event <- event.on("ping")

  io.debug("ping!")
  io.debug(event)

  let decoder = {
    use pong <- decode.subfield(["detail  ", "ping"], decode.string)

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

pub fn pong_decoder(_) {
  // use pong <- decode.subfield(["data", "pong"], decode.string)
  // decode.success()
  io.debug("decoding spong!")
  // Ok(UserSentPong("New pong data!"))
  // todo
}
