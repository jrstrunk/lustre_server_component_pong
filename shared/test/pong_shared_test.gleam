import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

import pong/shared

pub fn encode_model_test() {
  let model =
    shared.Model(pongs: ["hello"], current_pong: "")
  let encoded_model = shared.encode_model(model)
  let decoded_model = shared.decode_model(encoded_model)

  should.equal(decoded_model, model)
}
