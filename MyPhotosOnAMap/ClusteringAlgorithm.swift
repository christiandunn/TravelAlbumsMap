//
//  ClusteringAlgorithm.swift
//  MyPhotosOnAMap
//
//  Created by Christian Dunn on 5/6/16.
//  Copyright © 2016 Christian Dunn. All rights reserved.
//

import Foundation

public class Cluster {
    public var Center : CGPoint;
    public var Points : [CGPoint];
    
    init(withCenter center : CGPoint, andPoints points : [CGPoint]) {
        Center = center;
        Points = points;
    }
}

public class ClusteringAlgorithm<PointDataType> {
    
    var MaxDistanceAwayFromCenterOfCluster : Double;
    
    init(withMaxDistance distance : Double) {
        MaxDistanceAwayFromCenterOfCluster = distance;
    }
    
    public func kMeans<PointDataType>(points: [(CGPoint, PointDataType)]) -> ([(CGPoint, [PointDataType])], [Double], [Int], [Cluster]) {
        let initialEstimate = _estimateK(points: points.map({$0.0}));
        var (k, initialCenters) = (min(initialEstimate.0, points.count), initialEstimate.1);
        var maxmaxD = 0.0;
        var (clusterCenters, maxD, clusterCounts, clusters) = _kMeans(k: k, initialCenters: initialCenters, points: points);
        maxmaxD = maxD.reduce(0.0) {max($0, $1)};
        while maxmaxD > (MaxDistanceAwayFromCenterOfCluster) && k < 100 {
            if k < points.count {
                k = k + 1;
                initialCenters.append(_pointFarthestAway(centers: initialCenters, points: points.map({$0.0})));
            }
            (clusterCenters, maxD, clusterCounts, clusters) = _kMeans(k: k, initialCenters: initialCenters, points: points);
            maxmaxD = maxD.reduce(0.0) {max($0, $1)};
            //print("k = \(k), maxmaxD = \(maxmaxD)");
        }
        return (clusterCenters, maxD, clusterCounts, clusters);
    }
    
    private func _pointFarthestAway(centers: [CGPoint], points: [CGPoint]) -> CGPoint {
        let farthestPoint = points.reduce((points[0], 0), {(farthestPoint, newPoint) -> (CGPoint, Double) in
            let minDistanceToCluster = centers.reduce(9999999.0, {(minDistance, nextCluster) -> Double in min(minDistance, Double(_pointDistance(point: nextCluster, pt: newPoint)))});
            if minDistanceToCluster > farthestPoint.1 {
                return (newPoint, minDistanceToCluster);
            }
            return farthestPoint;
        });
        return farthestPoint.0;
    }
    
    private func _estimateK(points: [CGPoint]) -> (Int, [CGPoint]) {
        var k : Int = 1;
        var centers : [CGPoint] = [CGPoint]();
        for point in points {
            var foundClique = false;
            for center in centers {
                if Double(_pointDistance(point: center, pt: point)) < (MaxDistanceAwayFromCenterOfCluster) {
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
    
    private func _kMeans<PointDataType>(k: Int, initialCenters: [CGPoint], points: [(CGPoint, PointDataType)]) -> ([(CGPoint, [PointDataType])], [Double], [Int], [Cluster]) {
        var centers : [(CGPoint, [PointDataType])] = [(CGPoint, [PointDataType])]();
        var closest : [((CGPoint, PointDataType), Int)] = points.map {($0, 0)};
        var centersMaxD = [Double]();
        var centersCount = [Int]();
        var clusters : [Cluster] = [Cluster]();
        if k != initialCenters.count {
            print("K cannot be different from the number of initial cluster centers");
        }
        for i in 1...k {
            centers.append((initialCenters[i-1], []));
            centersMaxD.append(0.0);
            centersCount.append(0);
            clusters.append(Cluster.init(withCenter: initialCenters[i-1], andPoints: []));
        }
        for _ in 1...6 {
            for p in 0...(closest.count-1) {
                //Find the closest existing center of index c to the point p
                var distance = 9999999.0;
                for c in 0...(k-1) {
                    let d = Double(_pointDistance(point: closest[p].0.0, pt: centers[c].0));
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
                centers[c] = (CGPoint(x:CGFloat(newX), y:CGFloat(newY)), mediaObjects);
                let maxD = pset.reduce(0) {max($0, _pointDistance(point: $1.0.0, pt: centers[c].0))};
                centersMaxD[c] = Double(maxD);
                centersCount[c] = pset.count;
            }
        }
        clusters = closest.reduce(clusters, {
            (existingObj, newObj) -> [Cluster] in
            let index = newObj.1;
            let point = newObj.0.0;
            existingObj[index].Center = centers[index].0
            existingObj[index].Points.append(point);
            return existingObj;
        })
        return (centers, centersMaxD, centersCount, clusters);
    }
    
    private func _pointDistance(point: CGPoint, pt: CGPoint) -> CGFloat {
        let distance = pow(pow(point.x - pt.x, 2) + pow(point.y - pt.y, 2), 0.5);
        return distance;
    }
}
