import React, { useState, useEffect } from 'react';
import { encode } from './tens';

function bitLength(integer) {
  if (integer <= 0) {
    return 0;
  }
  let length = 0;
  while((2 ** length) <= integer) {
    length += 1;
  }
  return length;
}

const irSizes = [
  3,4,5,6,7,8,9
];

const colors = [
  'gray',
  'red',
  'green',
  'blue',
  'rgb',
  'gray_inverted',
  'brown',
  'purple',
  'bgr',
  'brg',
  'grb',
  'gbr',
  'rbg',
  'yellow',
  'aqua',
];

function generateValidIrSizes(minIrSize) {
  let newIrSizes = [];
  let idx = 0;
  while(idx < irSizes.length) {
    if (irSizes[idx] >= minIrSize) {
      newIrSizes.push(irSizes[idx]);
    }
    idx += 1;
  }

  // console.log(`New virs: ${newIrSizes} from ${minIrSize}`)
  return newIrSizes;
}

function Root() {
    // Hardcoded to TensArtV1.all_internal_tokens.length
    const internalTokensCount = 21;
    const startingMinIrSize = bitLength(internalTokensCount);
    const startingValidIrSizes = generateValidIrSizes(startingMinIrSize);
    const [minIrSize, setMinIrSize] = useState(startingMinIrSize);
    const [encoderVersion, setEncoderVersion] = useState("v1-ehv")
    const [message, setMessage] = useState("hello dark world");
    const [color, setColor] = useState("gray");
    const [beginEncoding, setBeginEncoding] = useState(false);
    const [imageData, setImageData] = useState(null);
    const [scaledImageData, setScaledImageData] = useState(null);
    const [irSize, setIrSize] = useState(startingMinIrSize);
    const [validIrSizes, setValidIrSizes] = useState(startingValidIrSizes);

    useEffect(() => {
      if(beginEncoding) {
        async function asyncEffect() {
          const encodedResult = JSON.parse(await encode(message, color, irSize));
          setImageData(encodedResult.o)
          setScaledImageData(encodedResult.s)
          // console.log(imageData);
        }
        asyncEffect()
        .catch(console.error);
      } else {
        console.log("No encoding just yet");
      }
      () => { 
        // console.log("Ending effect");
      };
    }, [beginEncoding]);

    function MessageForm() {
      function handleChange(e) {
        setMessage(e.target.value);
        const uniqueCharacters = new Set(...e.target.value.split()).size;
        const newMinIrSize = bitLength(internalTokensCount + uniqueCharacters);
        if(newMinIrSize != minIrSize) {
          setMinIrSize(newMinIrSize);
          const newIrSizes = generateValidIrSizes(newMinIrSize);
          setValidIrSizes(newIrSizes);
          if(irSize < newMinIrSize) {
            // console.log(`Setting IR Size to: ${newMinIrSize}`);
            setIrSize(newMinIrSize);
          }
        }
      }

      return(
        <div className="form-element-container">
          <div>
            Text to Encode
            <br/>
          </div>
          <label>
            <textarea value={message} onChange={handleChange} />
          </label>
        </div>
      );
    }

    function ColorForm() {
      function handleChange(e) {
        setColor(e.target.value);
      }

      function colorInput(colorValue) {
        return (
          <option
            key={`ci-${colorValue}`}
            value={colorValue}
          >
          {colorValue}
          </option>
        )
      }

      return (
        <div className="form-element-container">
          Color
          <br/>
          <select className="tens-color" value={color} onChange={handleChange}>
          {colors.map(colorInput)}
          </select>
        </div>
      )
    }

    function IrSizeForm() {
      function handleChange(e) {
        let integer = parseInt(e.target.value);
        if(integer >= minIrSize) {
          setIrSize(integer);
        }
      }

      function irSizeInput(irSizeValue) {
        let disabled = validIrSizes[0] > irSizeValue;
        return (
          <div className="ir-size-ind-container" key={`irs-div-${irSizeValue}`}>
          <input 
            type='radio'
            name='irSize'
            value={irSizeValue}
            key={`irs-${irSizeValue}`}
            checked={irSizeValue == irSize}
            onChange={handleChange}
            disabled={disabled}
          />
          {`${irSizeValue}`}
          </div>
        )
      }

      return (
        <div className="form-element-container">
        Internal Representation Size (Bits)
        <br/>
        <div className='ir-size-all-container'>
          {irSizes.map(irSizeInput)}
        </div>
        </div>
      )

    }

    function Image() {
      if(imageData != null) {
        let dataUri = "data:image/png;base64, " + imageData;
        let imageDataBytes = imageData.length
        let scaledDataUri = "data:image/png;base64, " + scaledImageData;
        return(
          <div className='break-word' >
            {Header()}
            <h2> 1010s </h2>
            <img src={dataUri}/>
            <h4> scaled (for viewing) </h4>
            <img src={scaledDataUri}/>
            <p> Base 64 Size: {imageDataBytes} Bytes </p>
            <p> Color: {color} </p>
            <p> IR Size: {irSize} </p>
            <p> Encoder: {encoderVersion} </p>
            <p> Message: {message} </p>
            <p> Base 64 Image: {imageData} </p>
            {Footer()}
          </div>
        )
      } else {
        return(
          <div> 
            {Header()}
            <h2>Creating your 1010s ... </h2>
          </div>
        );
      }
    }

    function EncodeButton() {
      function handleSubmit(event) {
        console.log("Beginning encoding.....");
        setBeginEncoding(true);
        event.preventDefault();
      }

      return(
        <form onSubmit={handleSubmit}>
          <input type="submit" className="tens-submit" value="Create 1010s" />
        </form>
      )
    }

    function Header() {
      return(
        <div>
          <br/>
          <br/>
        </div>
      )
    }

    function Footer() {
      return(
        <div>
          <br/>
          <br/>
          <br/>
          <h5> Built for ErgoHackV </h5>
          <h5> By Dark Lord of Programming </h5>
        </div>
      )
    }

    function rootBody(imageData) {
      if(beginEncoding) {
        return(
          <div>
            {Image()}
          </div>
        )
      } else {
        return(
          <div>
            {Header()}
            <h2> Create a 1010s </h2>
            <h4> Encoder: {encoderVersion} </h4>
            <br/>
            {MessageForm()}
            {IrSizeForm()}
            {ColorForm()}
            {EncodeButton()}
            {Footer()}
          </div>
        )
      }
    }

    return(
      <div>
        {rootBody(imageData)}
      </div>
    )
}

export default Root;
