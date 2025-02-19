import gleam/result
import lustre
import plinth/browser/document
import plinth/browser/element
import pong/shared

pub fn main() {
  let assert Ok(encoded_model) =
    document.query_selector("#model")
    |> result.map(element.inner_text)

  let flags = shared.decode_model(encoded_model)

  let app = lustre.application(shared.init, shared.update, shared.view)
  let assert Ok(_) = lustre.start(app, "#app", flags)

  Nil
}
