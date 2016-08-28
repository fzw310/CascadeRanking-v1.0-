###################################################################
#                                                                 #
#        Refine BING using Effective Cascade Ranking V1.0         #
#                                                                 #
#                                                                 #
###################################################################

The software was developed under windows with Matlab 2014a and VS2013.
- The code has been test on 64-bit Windows 7 and 64-bit Windows 10 systems respectively.
- 64-bit Matlab is required. 

1. Introduction.

To reduce the false positive rate, an effective and efficient cascade ranking method is proposed to refine BING. First, the concept of scale-sets histogram is novelly introduced. It helps to analyze the potential sizes of the objects. Secondly, more descriptive visual features (i.e. the color-texture consistence) are considered simultaneously for objectness characterization. Lastly, we propose hierarchical sorting to further leverage the ranking performance, according to the local contrast analysis between the inside and straddling superpixels of the object proposal windows. 

###################################################################

2. License.

Copyright (C) 2016 Fang zhiwen 

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. 

###################################################################


3. Installation.

- Run "compile.m" to compile the .cpp files.

4. Getting Started.

- Make sure the .cpp files are compiled successfully.
- Please load the default parameters and update the paths of the test images in "default_parameters.m".
- Please see "main.m" to run demos.


5. Others
- Our software only needs the images on datasets. Other files have been saved as mat-files. 
These images can be downloaded from the dataset homepages or the following links.
  Images for testing on VOC2007: http://pan.baidu.com/s/1jIhf9aA
  Images for testing on VOC2010: http://pan.baidu.com/s/1gfFH8Ev
  Images for testing on VOC2012: http://pan.baidu.com/s/1o7WieeA
  Images for testing on ImageNet: part1 : http://pan.baidu.com/s/1o86FR4I
                                  part2 : http://pan.baidu.com/s/1nuDnqIX

- If you use our codes, please cite our papers.








