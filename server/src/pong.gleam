import gleam/erlang/process
import gleam/http/request
import lustre
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/server_component as lustre_server_component
import mist
import ping
import pong/shared
import server_component
import wisp
import wisp/wisp_mist

pub fn main() {
  let assert Ok(ping_actor) =
    lustre.start_actor(ping.app(), ping.Model(pings: []))

  let assert Ok(_) =
    handler(_, ping_actor)
    |> mist.new
    |> mist.port(8401)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}

fn handler(req, context) {
  case request.path_segments(req) {
    ["lustre-server-component.mjs"] -> server_component.serve_lustre_framework()

    ["styles.css"] -> server_component.serve_css("styles.css")

    ["client"] -> server_component.serve_js("pong_client.mjs")

    ["ping-component"] -> server_component.get_connection(req, context)

    _ -> wisp_mist.handler(handle_wisp_request(_, context), "secret")(req)
  }
}

fn handle_wisp_request(req, _context) {
  let model = shared.Model(pongs: ["hello"], current_pong: "")

  case request.path_segments(req) {
    [] ->
      html.html([], [
        html.head([], [
          html.script(
            [attribute.type_("application/json"), attribute.id("model")],
            shared.encode_model(model),
          ),
          html.script([attribute.type_("module"), attribute.src("client")], ""),
          lustre_server_component.script(),
        ]),
        html.body([], [
          element.element(
            "lustre-server-component",
            [lustre_server_component.route("/ping-component")],
            [
              html.div([attribute.attribute("slot", "client-input")], [
                html.div([attribute.id("app")], [shared.view(model)]),
              ]),
            ],
          ),
        ]),
      ])
      |> element.to_document_string_builder
      |> wisp.html_response(200)

    _ -> wisp.not_found()
  }
}
