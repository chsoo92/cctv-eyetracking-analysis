# cctv-eyetracking-analysis

# Background

This project is from the follow-up research on https://github.com/chsoo92/cctv-eyetracking-analysis/blob/master/VSS16Poster_Joseph.pdf

Previous experiments obtained CCTV eye-tracking data of 4 action categories (confront, play, nothing, and fight) from novices and experts. There were 9 videos for each circumstance; each video is 40 frames long. According to Itti's saliency model for the fixation area in the videos, novices and experts showed a marginally significant difference on the saliency of their looking area near the end of videos (last 2 seconds among the entire 16 s), averaging across 4 video categories. The effect was marginally significant for both 38 pixel diameter (p = 0.092) and 75 pixel diameter (p = 0.076). Experts got higher saliency indices than novices. By looking at the four action categories separately, there was no significant difference between experts and novices.

Deep Learning Decoding

The eye=tracking data were fed into to a deep learning model (AlexNet), and high-level features from the deep fully-connected layer (fc7) were extracted. However, logistic regression of action category on the extracted feature (elastic net regularization), showed that only the fighting category yielded a significantly accurate result (M = 0.68, p = 0.006). Interestingly, the last chunk from the fighting videos had a disproportional influence on the classification.

The goals of this data analysis:
> 1. Explore which frames of the videos are consistently represented in the deep layer, across different categories and groups. 
2. Explore how different frame groupings influence intergroup/category similarity.

# Data

Since 'fea_fc7_all_v3' is a 21x4096x40x36 multidimensional array, it is too heavy to be uploaded here.
> 21 participants(10 novices and 11 experts) 
>36 videos (4 action categories, 9 videos for each category).
>Each video consists of 40 frames.
>For each frame, the extracted features are represented in 1 x 4096 

To quantify consistency, correlation and cosine distance of the deep layer features.



# Result



See summary2.pdf and summary3.pdf for detailed information.






