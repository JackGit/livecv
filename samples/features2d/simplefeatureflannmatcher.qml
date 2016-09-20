import lcvcore 1.0
import lcvimgproc 1.0
import lcvfeatures2d 1.0

Column{
    
    // Flann based matcher
	
    // Usage of FlannBasedMatcher on Brief descriptors to find matches 
    // between two images
	
    property string trainImage : codeDocument.path + '/../_images/clock-train-small.jpg'
    property string queryImage : codeDocument.path + '/../_images/clock-query-room-small.jpg'
    
    Row{
    
        // Train images

        ImRead{
            id: trainImageLoader
            visible : false
            file : trainImage
        }

        FastFeatureDetector{
            id : trainFeatureDetect
            input : trainImageLoader.output
        }

        BriefDescriptorExtractor{
            keypoints : trainFeatureDetect.keypoints
            Component.onCompleted : {
                descriptorMatcher.add(descriptors)
                descriptorMatcher.train();
            }
        }

        // Query Image

        ImRead{
            id : queryImageLoader
            visible : false
            file : queryImage
        }

        FastFeatureDetector{
            id : queryFeatureDetect
            input : queryImageLoader.output
        }

        BriefDescriptorExtractor{
            id : queryFeatureExtract
            keypoints : queryFeatureDetect.keypoints
        }
    
    }
    
    // Matching
     
    FlannBasedMatcher{
        id : descriptorMatcher
        queryDescriptors : queryFeatureExtract.descriptors
        knn : 2
        params : {'indexParams' : 'Lsh'}
    }
    
    DescriptorMatchFilter{
        id: descriptorMatchFilter
        matches1to2: descriptorMatcher.matches
        minDistanceCoeff: 2.5
        nndrRatio: 0.8
    }
       
    DrawMatches{
        keypoints1 : queryFeatureDetect.keypoints
        keypoints2 : trainFeatureDetect.keypoints
        matches1to2 : descriptorMatchFilter.matches1to2Out
        matchIndex : 0
    }
    
}
