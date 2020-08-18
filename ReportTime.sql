
 SELECT TOP 10 Itempath,parameters, 
      TimeDataRetrieval + TimeProcessing + TimeRendering as [total time],
      TimeDataRetrieval, TimeProcessing, TimeRendering,
      ByteCount, [RowCount],Source, AdditionalInfo
 FROM ExecutionLog3
 ORDER BY Timestart DESC


http://www.keepitsimpleandfast.com/2011/07/more-tips-to-improve-performance-of.html