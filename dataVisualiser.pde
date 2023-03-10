public class DataVisualiser {
  BarChart clusterSizesChart;
  int x, y, innerWidth, innerHeight;
  PApplet papplet;
  float[] clusterSizeCounts;
  float[] compressedClusterSizeCounts;
  String[] clusterSizeLabels;
  
  DataVisualiser(PApplet papplet, int x, int y, int innerWidth, int innerHeight) {
    this.x = x;
    this.y = y;
    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;
    this.papplet = papplet;
  }
  
  public void update() {
    noStroke();
    rect(x,y,innerWidth,innerHeight);
    clusterSizesChart.setData(compressedClusterSizeCounts);
    clusterSizesChart.setBarLabels(clusterSizeLabels);
    clusterSizesChart.setBarColour(color(200,80,80,100));
    clusterSizesChart.setBarGap(2);
    clusterSizesChart.showValueAxis(true);
    clusterSizesChart.setValueAxisLabel("Number of clusters");
    clusterSizesChart.showCategoryAxis(true);
    clusterSizesChart.setCategoryAxisLabel("Cluster size (# agents)");
    clusterSizesChart.setMinValue(0);
    clusterSizesChart.draw(x+10, y+10, innerWidth/2-20, innerHeight/2-20);
  }
  
  public void updateClusterCounts(int[] agentsPerCluster) {
    for (int index = 0; index < agentsPerCluster.length; index++) {
      clusterSizeCounts[agentsPerCluster[index]]++;
    }
    for (int index = clusterSizeCounts.length - 1; index >=0; index--) {
      if (clusterSizeCounts[index] == 0) {
        continue;
      }
      clusterSizeLabels = new String[index+1];
      compressedClusterSizeCounts = new float[index+1];
      for (int j_index = 0; j_index < index + 1; j_index++) {
        if (index + 1 > 10) {
          if (j_index % ceil(float(index+1)/10.0) == 0) { // Prevents too many labels -> causes overlapping
            clusterSizeLabels[j_index] = str(j_index);
          } else {
            clusterSizeLabels[j_index] = "";
          }
        } else {
          clusterSizeLabels[j_index] = str(j_index);
        }
        compressedClusterSizeCounts[j_index] = clusterSizeCounts[j_index];
      }
      break;
    }
  }
  
  public void reset() {
    compressedClusterSizeCounts = new float[]{};
    clusterSizeCounts = new float[config.getNumAgents()];
    Arrays.fill(clusterSizeCounts, 0);
    clusterSizeLabels = new String[]{};
    clusterSizesChart = new BarChart(papplet);
  }
}
