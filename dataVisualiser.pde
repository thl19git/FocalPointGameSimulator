public class VisAndInfoPanel {
  private BarChart clusterSizesChart;
  private BarChart winRateByClusterSizeChart;
  private BarChart winRateByMonumentProximityChart;
  private XYChart winRateChart;
  private int x, y, innerWidth, innerHeight;
  private PApplet papplet;
  private float[] clusterSizeCounts;
  private float[] compressedClusterSizeCounts;
  private float[] winsByClusterSize;
  private float[] compressedWinRateByClusterSize;
  private float[] monumentProximityCounts;
  private float[] winsByMonumentProximity;
  private float[] compressedWinRateByMonumentProximity;
  private String[] monumentProximityLabels;
  private String[] clusterSizeLabels;
  private ArrayList<PVector> winRatesData;
  private String itemBeingPlaced;
  private String errorText = "";

  VisAndInfoPanel(PApplet papplet, int x, int y, int innerWidth, int innerHeight) {
    this.x = x;
    this.y = y;
    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;
    this.papplet = papplet;
  }

  public void update() {
    noStroke();
    fill(255);
    rect(x, y, innerWidth, innerHeight);
    switch (server.getStage()) {
    case CONFIGURATION:
      showConfigurationText();
      break;
    case PLACING:
      showPlacingText();
      if (errorText != "") {
        showErrorText();
      }
      break;
    default:
      updateClusterSizesChart();
      updateWinRateChart();
      updateWinRateByClusterSizeChart();
      if (!config.getLocalisedMonuments() && config.getNumMonuments() > 0) {
        updateWinRateByMonumentProximityChart();
      }
    }
  }

  public void showConfigurationText() {
    textSize(20);
    textAlign(LEFT);
    fill(0);
    text("Configuration:\n- Use the text cells to configure an experiment.\n- Any incompatibilities will be automatically fixed.\n- Number of clusters is ignored if district clusters are selected.\n- Click 'Configure' when finished.", x+50, y+50);
    fill(255);
  }

  public void showPlacingText() {
    textSize(20);
    textAlign(LEFT);
    fill(0);
    text("Currently placing: " + itemBeingPlaced + "\n\nClick on the leftmost button to toggle between item type.\n\nDistrict creation:\n- Drag the mouse to create districts if you wish.\n- Districts must be rectangular and cannot overlap.\n- If you have districts, the whole grid must be covered.\n\nMonument/Agent creation:\n- Click to place monuments/agents.\n- Any unplaced monuments/agents will be randomly placed.\n\nClick 'Reset' to remove all existing placed objects.\nClick 'Reset' again to return to the configuration stage.\nClick 'Start' when you have finished placing objects.", x+50, y+50);
    fill(255);
  }
  
  public void showErrorText() {
    textSize(20);
    textAlign(LEFT);
    fill(color(255,0,0));
    text("ERROR: " + errorText, x+50, y+innerHeight-100);
    fill(255);
  }

  public void updateClusterSizesChart() {
    clusterSizesChart.setData(compressedClusterSizeCounts);
    clusterSizesChart.setBarLabels(clusterSizeLabels);
    clusterSizesChart.setBarColour(color(200, 80, 80, 100));
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
    winRateChart.setPointColour(color(180, 50, 50, 100));
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
  
  private void updateWinRateByClusterSizeChart() {
    winRateByClusterSizeChart.setData(compressedWinRateByClusterSize);
    winRateByClusterSizeChart.setBarLabels(clusterSizeLabels);
    winRateByClusterSizeChart.setBarColour(color(200, 80, 80, 100));
    winRateByClusterSizeChart.setBarGap(2);
    winRateByClusterSizeChart.showValueAxis(true);
    winRateByClusterSizeChart.setValueFormat("#%");
    winRateByClusterSizeChart.setValueAxisLabel("Win rate");
    winRateByClusterSizeChart.showCategoryAxis(true);
    winRateByClusterSizeChart.setCategoryAxisLabel("Cluster size (# agents)");
    winRateByClusterSizeChart.setMinValue(0);
    winRateByClusterSizeChart.draw(x+10, y+innerHeight/2+10, innerWidth/2-20, innerHeight/2-20);
  }
  
  private void updateWinRateByMonumentProximityChart() {
    winRateByMonumentProximityChart.setData(compressedWinRateByMonumentProximity);
    winRateByMonumentProximityChart.setBarLabels(monumentProximityLabels);
    winRateByMonumentProximityChart.setBarColour(color(200, 80, 80, 100));
    winRateByMonumentProximityChart.setBarGap(2);
    winRateByMonumentProximityChart.showValueAxis(true);
    winRateByMonumentProximityChart.setValueFormat("#%");
    winRateByMonumentProximityChart.setValueAxisLabel("Win rate");
    winRateByMonumentProximityChart.showCategoryAxis(true);
    winRateByMonumentProximityChart.setCategoryAxisLabel("Monument proximity (distance)");
    winRateByMonumentProximityChart.setMinValue(0);
    winRateByMonumentProximityChart.draw(x+innerWidth/2-10, y+innerHeight/2+10, innerWidth/2-20, innerHeight/2-20);
  }
  
  public void addWinningClusterSizes(ArrayList<Integer> winningClusterSizes) {
    for (int size : winningClusterSizes) {
      winsByClusterSize[size]++;
    }
    
     compressedWinRateByClusterSize = new float[compressedClusterSizeCounts.length];
     for (int index = 0; index < compressedClusterSizeCounts.length; index++) {
       if (compressedClusterSizeCounts[index] == 0) {
         compressedWinRateByClusterSize[index] = 0;
       } else {
         compressedWinRateByClusterSize[index] = winsByClusterSize[index] / compressedClusterSizeCounts[index];
       }
     }
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
  
  public void updateWinRateByMonumentProximity(boolean[] results, float[] distances) {
    for (int index = 0; index < results.length; index++) {
      int distance = floor(distances[index]);
      monumentProximityCounts[distance]++;
      if (results[index]) {
        winsByMonumentProximity[distance]++;
      }
    }
    
    for (int index = monumentProximityCounts.length - 1; index >=0; index--) {
      if (monumentProximityCounts[index] == 0) {
        continue;
      }
      monumentProximityLabels = new String[index+1];
      compressedWinRateByMonumentProximity = new float[index+1];
      for (int j_index = 0; j_index < index + 1; j_index++) {
        if (index + 1 > 10) {
          if (j_index % ceil(float(index+1)/10.0) == 0) { // Prevents too many labels -> causes overlapping
            monumentProximityLabels[j_index] = str(j_index)+" - "+str(j_index+1);
          } else {
            monumentProximityLabels[j_index] = "";
          }
        } else {
          if (index < 6 || j_index%2 == 0) {
            monumentProximityLabels[j_index] = str(j_index)+" - "+str(j_index+1);
          } else {
            monumentProximityLabels[j_index] = "";
          }
        }
        if (monumentProximityCounts[j_index] == 0) {
          compressedWinRateByMonumentProximity[j_index] = 0;
        } else {
          compressedWinRateByMonumentProximity[j_index] = winsByMonumentProximity[j_index] / monumentProximityCounts[j_index];
        }
      }
      break;
    }
  }

  public void setItemBeingPlaced(String itemBeingPlaced) {
    this.itemBeingPlaced = itemBeingPlaced;
  }
  
  public void setErrorText(String errorText) {
    this.errorText = errorText;
  }
  
  public void logFinalStatistics(DataLogger dataLogger) {
    dataLogger.logFinalStatistics(clusterSizeCounts, winsByClusterSize, monumentProximityCounts, winsByMonumentProximity, winRatesData, config);
  }

  public void reset() {
    compressedClusterSizeCounts = new float[]{}; //remove?
    clusterSizeCounts = new float[config.getNumAgents()+1];
    compressedWinRateByClusterSize = new float[]{}; //remove?
    winsByClusterSize = new float[config.getNumAgents()+1];
    monumentProximityCounts = new float[ceil(config.getGridSize()*sqrt(2))];
    winsByMonumentProximity = new float[ceil(config.getGridSize()*sqrt(2))];
    compressedWinRateByMonumentProximity = new float[]{}; //remove?
    Arrays.fill(clusterSizeCounts, 0);
    clusterSizeLabels = new String[]{}; //remove?
    winRatesData = new ArrayList<PVector>();
    clusterSizesChart = new BarChart(papplet);
    winRateByClusterSizeChart = new BarChart(papplet);
    winRateByMonumentProximityChart = new BarChart(papplet);
    winRateChart = new XYChart(papplet);
  }
}
