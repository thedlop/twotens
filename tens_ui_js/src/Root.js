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
    const [encoderVersion, setEncoderVersion] = useState("ehv-v1")
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
        <label>
          <textarea value={message} onChange={handleChange} />
        </label>
      );
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
          <div>
          <input 
            type='radio'
            name='irSize'
            value={irSizeValue}
            key={`irs-${irSizeValue}`}
            checked={irSizeValue == irSize}
            onChange={handleChange}
            disabled={disabled}
          />
          {`${irSizeValue} bit`}
          <br/>
          </div>
        )
      }

      return (
        <div>
        {irSizes.map(irSizeInput)}
        </div>
      )

    }

    function Image() {
      if(imageData != null) {
        let dataUri = "data:image/png;base64, " + imageData;
        let imageDataBytes = 8 * imageData.length
        let scaledDataUri = "data:image/png;base64, " + scaledImageData;
        return(
          <div>
            <p> 1010s </p>
            <img src={dataUri}/>
            <p> Base 64 Size: {imageDataBytes} Bytes </p>
            <p> Message: {message} </p>
            <p> Color: {color} </p>
            <p> IR Size: {irSize} </p>
            <p> Encoder: {encoderVersion} </p>
            <p> Base 64 Image: {imageData} </p>
            <p> scaled (for viewing) </p>
            <img src={scaledDataUri}/>
          </div>
        )
      } else {
        return(
          <div>
            Creating your 1010s... 
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
          <input type="submit" value="Create 1010s" />
        </form>
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
            {MessageForm()}
            {IrSizeForm()}
            {EncodeButton()}
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
