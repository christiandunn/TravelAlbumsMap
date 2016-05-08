//
//  ClusteringAlgorithm.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 5/6/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class ClusteringAlgorithm<PointDataType> {
    
    var MaxDistanceAwayFromCenterOfCluster : Double;
    
    init(withMaxDistance distance : Double) {
        MaxDistanceAwayFromCenterOfCluster = distance;
    }
    
    public func kMeans<PointDataType>(points: [(CGPoint, PointDataType)]) -> ([(CGPoint, [PointDataType])], [Double], [Int]) {
        let initialEstimate = _estimateK(points.map({$0.0}));
        var (k, initialCenters) = (min(initialEstimate.0, points.count), initialEstimate.1);
        var maxmaxD = 0.0;
        var (clusterCenters, maxD, clusterCounts) = _kMeans(k, initialCenters: initialCenters, points: points);
        maxmaxD = maxD.reduce(0.0) {max($0, $1)};
        while maxmaxD > (MaxDistanceAwayFromCenterOfCluster) && k < 100 {
            k = min(k + 1, points.count);
            (clusterCenters, maxD, clusterCounts) = _kMeans(k, initialCenters: initialCenters, points: points);
            maxmaxD = maxD.reduce(0.0) {max($0, $1)};
            print("k = \(k), maxmaxD = \(maxmaxD)");
        }
        return (clusterCenters, maxD, clusterCounts);
    }
    
    private func _estimateK(points: [CGPoint]) -> (Int, [CGPoint]) {
        var k : Int = 1;
        var centers : [CGPoint] = [CGPoint]();
        for point in points {
            var foundClique = false;
            for center in centers {
                if Double(_pointDistance(center, pt: point)) < (MaxDistanceAwayFromCenterOfCluster) {
                    foundClique = true;
                }
            }
            if !foundClique {
                centers.append(point);
            }
        }
        k = centers.count;
        return (k, centers);
    }
    
    private func _kMeans<PointDataType>(k: Int, initialCenters: [CGPoint], points: [(CGPoint, PointDataType)]) -> ([(CGPoint, [PointDataType])], [Double], [Int]) {
        var centers : [(CGPoint, [PointDataType])] = [(CGPoint, [PointDataType])]();
        var closest : [((CGPoint, PointDataType), Int)] = points.map {($0, 0)};
        var centersMaxD = [Double]();
        var centersCount = [Int]();
        for i in 1...k {
            centers.append((initialCenters[i-1], []));
            centersMaxD.append(0.0);
            centersCount.append(0);
        }
        for _ in 1...6 {
            for p in 0...(closest.count-1) {
                //Find the closest existing center of index c to the point p
                var distance = 9999999.0;
                for c in 0...(k-1) {
                    let d = Double(_pointDistance(closest[p].0.0, pt: centers[c].0));
                    if d < distance {
                        distance = d;
                        var oldClosest = closest[p];
                        oldClosest.1 = c;
                        closest[p] = oldClosest;
                    }
                }
            }
            //Recalculate the centers
            for c in 0...(k-1) {
                let pset = closest.filter {$0.1 == c};
                let (mediaObjects, newX, newY) : ([PointDataType], Double, Double) = pset.reduce(([PointDataType](), 0.0, 0.0)) {
                    (existingObj, newObj) -> ([PointDataType], Double, Double) in
                    var arr = existingObj.0;
                    arr.append(newObj.0.1);
                    let x = existingObj.1 + Double(newObj.0.0.x) / Double(pset.count);
                    let y = existingObj.2 + Double(newObj.0.0.y) / Double(pset.count);
                    return (arr, x, y);
                };
                centers[c] = (CGPointMake(CGFloat(newX), CGFloat(newY)), mediaObjects);
                let maxD = pset.reduce(0) {max($0, _pointDistance($1.0.0, pt: centers[c].0))};
                centersMaxD[c] = Double(maxD);
                centersCount[c] = pset.count;
            }
        }
        return (centers, centersMaxD, centersCount);
    }
    
    private func _pointDistance(point: CGPoint, pt: CGPoint) -> CGFloat {
        let distance = pow(pow(point.x - pt.x, 2) + pow(point.y - pt.y, 2), 0.5);
        return distance;
    }
}