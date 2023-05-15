public class DataVisualiser {
  private BarChart clusterSizesChart;
  private XYChart winRateChart;
  private int x, y, innerWidth, innerHeight;
  private PApplet papplet;
  private float[] clusterSizeCounts;
  private float[] compressedClusterSizeCounts;
  private String[] clusterSizeLabels;
  private ArrayList<PVector> winRatesData;
  
  DataVisualiser(PApplet papplet, int x, int y, int innerWidth, int innerHeight) {
    this.x = x;
    this.y = y;
    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;
    this.papplet = papplet;
  }
  
  public void update() {
    noStroke();
    fill(255);
    rect(x,y,innerWidth,innerHeight);
    switch (server.getStage()) {
      case CONFIGURATION:
        showConfigurationText();
        break;
      case PLACING:
        showPlacingText();
        break;
      default:
        updateClusterSizesChart();
        updateWinRateChart();
    }
  }
  
  public void showConfigurationText() {
    textSize(20);
    textAlign(LEFT);
    fill(0);
    text("Configuration:\n- Use the text cells to configure an experiment.\n- Any incompatibilities will be automatically fixed.\n- Click 'Configure' when finished.", x+50, y+50);
    fill(255);
  }
  
  public void showPlacingText() {
    textSize(20);
    textAlign(LEFT);
    fill(0);
    text("District creation:\n- Drag the mouse to create districts if you wish.\n- Districts must be rectangular and cannot overlap.\n- If you have districts, the whole grid must be covered.\n- Click 'Reset' to remove all existing districts.\n- Click 'Reset' again to return to the configuration stage.\n- Click 'Start' when you have finished creating districts.", x+50, y+50);
    fill(255);
  }
  
  public void updateClusterSizesChart() {
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
  
  public void updateWinRateChart() {
    if (winRatesData.size() == 0) {
      return;
    }
    winRateChart.setData(winRatesData);
    if (winRatesData.size() > 4) {
      winRateChart.showXAxis(true);
    }
    winRateChart.showYAxis(true);
    winRateChart.setPointColour(color(180,50,50,100));
    winRateChart.setPointSize(5);
    winRateChart.setLineWidth(2);
    winRateChart.setXAxisLabel("Round");
    winRateChart.setYAxisLabel("Win rate");
    winRateChart.setYFormat("#%");
    winRateChart.setXFormat("#");
    winRateChart.setMinX(0.5);
    winRateChart.setMaxX(winRatesData.size() + 0.5);
    winRateChart.setMinY(0);
    winRateChart.setMaxY(1);
    winRateChart.draw(x + innerWidth/2 + 10, y+10, innerWidth/2-20, innerHeight/2-20);
  }
  
  public void addNewWinRate(float winRate) {
    winRatesData.add(new PVector(winRatesData.size()+1, winRate));
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
    winRatesData = new ArrayList<PVector>();
    clusterSizesChart = new BarChart(papplet);
    winRateChart = new XYChart(papplet);
  }
}
