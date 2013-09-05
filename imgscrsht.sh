#!/bin/bash
################################################################################
#
# imss - ImageMagick ScreenShot utility.  Takes a screenshot with ImageMagick's
#        'import' command and saves to user's Desktop.  From the 'import'
#        manpage:
#            import - saves any visible window on an X server and outputs
#            it as an image file. You can capture a single window, the
#            entire screen, or any rectangular portion of the screen
#
#
# Modified from a script found at Web Design Tips, under the section "How to
# Take a Screenshot in GNOME With One Click" on the page titled "How to Take a
# Screenshot in Linux (Ubuntu)"
#  <http://tips.webdesign10.com/how-to-take-a-screenshot-on-ubuntu-linux>
#
# To use, simply invoke the script.  The mouse pointer will change to a
# crosshair, which can be used to outline a rectangular section by left-clicking
# the mouse and dragging over the desired area on the desktop.  To take a
# snapshot of a whole window (including the desktop's themed window border),
# simply click on the desired window app without dragging the mouse.  Two beeps
# will sound, one at the start of the screenshot creation and one immediately
# after the image is created.  For small screenshots (or very fast machines),
# it will sound like a double-beep.
#
################################################################################

# We'll create an unusual filename based on the number of seconds since
# "1970-01-01 00:00:00 UTC" so we don't accidentally overwrite another screen-
# shot.  This will also allow screenshots to be automatically stored in the
# order they were taken:
import -frame -strip -quality 80 "$HOME/Desktop/screenshot-$(date +%s).png"

exit 0

################################################################################
##
## Explanation of options used:
##    -strip  strip the image of any profiles or comments
##
##
##    -frame  include the X window frame in the imported image
##
##
##  -quality  JPEG/MIFF/PNG compression level
##
##            For the MNG and PNG image formats, the quality value sets the zlib
##            compression level (quality / 10) and filter-type (quality % 10).
##            Compression levels range from 0 (fastest compression) to 100 (best
##            but slowest). For compression level 0, the Huffman-only strategy is
##            used, which is fastest but not necessarily the worst compression.
##
##            The default quality is 75, which means nearly the best compression
##            with adaptive filtering. The quality setting has no effect on the
##            appearance of PNG and MNG images, since the compression is always
##            lossless. (NOTE: Value of 80 seems to be the best compression
##            with adaptive filtering, as values from 81-89 have a larger file
##            size).
##
################################################################################
