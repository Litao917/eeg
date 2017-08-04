function tooBig = checkImageSizeForPrint(dpi, screenDPI, width, height)
    % CHECKIMAGESIZEFORPRINT Checks to see if the image that will be
    % produced in the print path is within certain bounds. This
    % undocumented helper function is for internal use.

    % This function is called during the print path.  See usage in
    % alternatePrintPath.m
    
    % Predict how big the image data will be based on the requested
    % resolution and image size.  Returns true if the image size is greater
    % than the limit in imwrite.
    
    % Copyright 2013 The MathWorks, Inc.

    tooBig = false;
    scaleFactor = dpi/screenDPI;
    expectedWidth = width*scaleFactor;
    expectedHeight = height*scaleFactor;

    % Like imwrite, validate that the dataset/image will fit within 32-bit
    % offsets.
    max32 = double(intmax('uint32'));

    % If one of the dimensions is larger than max32, or if the number of
    % elements in the data (width*height*3 for RGB data) is larger than
    % max32, then we won't be able to write this image out using imwrite.
    if expectedWidth > max32 || expectedHeight > max32
        tooBig = true;
    elseif ((expectedWidth * expectedHeight * 3) > max32)
        tooBig = true;
    end
end
