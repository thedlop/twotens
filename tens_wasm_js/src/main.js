import { TensEncoder } from './tens';

export async function encode(message,color,ir_size) {
  const tensInput = JSON.stringify(buildTensInput(message, color, ir_size));
  console.log(tensInput);
  let t = new TensEncoder(tensInput);
  return await t.instantiate();
}

function buildTensInput(message, color, ir_size) {
  let input = {};

  input.data = message;
  input.ir_size = ir_size;
  input.color_profile = color;
  console.log(input);
  return input;
}

// async function testMany() {
//   await encode("hello world", "gray", 6);
// }

// testMany();
