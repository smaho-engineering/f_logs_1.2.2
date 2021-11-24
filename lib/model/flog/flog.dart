import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';
import 'package:stack_trace/stack_trace.dart';

class FLog {
  // flogs data source
  static final _flogDao = FlogDao.instance;

  //local storage
  static final LogsStorage _storage = LogsStorage.instance;

  //logs configuration
  static LogsConfig _config = LogsConfig();

  // A private constructor. Allows us to create instances of FLog
  // only from within the FLog class itself.
  FLog._();

  //Public Methods:-------------------------------------------------------------
  /// logThis
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  /// @param type         the type
  static logThis({
    String className,
    String methodName,
    @required String text,
    @required LogLevel type,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    // prevent to write LogLevel.ALL and LogLevel.OFF to db
    if (![LogLevel.OFF, LogLevel.ALL].contains(type)) {
      _logThis(className, methodName, text, type, exception, dataLogType,
          stacktrace);
    }
  }

  /// trace
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static trace({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.TRACE, exception,
        dataLogType, stacktrace);
  }

  /// debug
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static debug({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.DEBUG, exception,
        dataLogType, stacktrace);
  }

  /// info
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static info({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.INFO, exception, dataLogType,
        stacktrace);
  }

  /// warning
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static warning({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.WARNING, exception,
        dataLogType, stacktrace);
  }

  /// error
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static error({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.ERROR, exception,
        dataLogType, stacktrace);
  }

  /// severe
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static severe({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.SEVERE, exception,
        dataLogType, stacktrace);
  }

  /// fatal
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  static fatal({
    String className,
    String methodName,
    @required String text,
    Exception exception,
    String dataLogType,
    StackTrace stacktrace,
  }) async {
    _logThis(className, methodName, text, LogLevel.FATAL, exception,
        dataLogType, stacktrace);
  }

  /// printLogs
  ///
  /// This will return array of logs and print them as a string using StringBuffer()
  static printLogs() async {
    print(Constants.PRINT_LOG_MSG);

    _getAllLogs().then((logs) {
      var buffer = StringBuffer();

      if (logs.length > 0) {
        logs.forEach((log) {
          buffer.write(Formatter.format(log, _config));
        });
        print(buffer.toString());
      } else {
        print("No logs found!");
      }
      buffer.clear();
    });
  }

  /// printDataLogs
  ///
  /// This will return array of logs grouped by dataType and print them as a string using StringBuffer()
  static printDataLogs(
      {List<String> dataLogsType,
      List<String> logLevels,
      int startTimeInMillis,
      int endTimeInMillis,
      FilterType filterType}) async {
    print(Constants.PRINT_DATA_LOG_MSG);

    _getAllSortedByFilter(
            filters: Filters.generateFilters(
                dataLogsType: dataLogsType,
                logLevels: logLevels,
                startTimeInMillis: startTimeInMillis,
                endTimeInMillis: endTimeInMillis,
                filterType: filterType))
        .then((logs) {
      var buffer = StringBuffer();

      if (logs.length > 0) {
        logs.forEach((log) {
          buffer.write(Formatter.format(log, _config));
        });
        print(buffer.toString());
      } else {
        print("No logs found!");
      }
      buffer.clear();
    });
  }

  /// printFileLogs
  ///
  /// This will print logs stored in a file as string using StringBuffer()
  static printFileLogs() async {
    print(Constants.PRINT_LOG_MSG);

    _storage.readLogsToFile().then((content) {
      print(content);
    });
  }

  /// exportLogs
  ///
  /// This will export logs to external storage under FLog directory
  static exportLogs() async {
    var buffer = StringBuffer();

    print(Constants.PRINT_EXPORT_MSG);

    //get all logs and write to file
    _getAllLogs().then((logs) {
      logs.forEach((log) {
        buffer.write(Formatter.format(log, _config));
      });

      _storage.writeLogsToFile(buffer.toString());
      print(buffer.toString());
      buffer.clear();
    });
  }

  /// getAllLogs
  ///
  /// This will return the list of logs stored in database
  static Future<List<Log>> getAllLogs() async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      return await _flogDao.getAllLogs();
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// getAllLogsByFilter
  ///
  /// This will return the list of logs stored based on the provided filters
  static Future<List<Log>> getAllLogsByFilter(
      {List<String> dataLogsType,
      List<String> logLevels,
      int startTimeInMillis,
      int endTimeInMillis,
      FilterType filterType}) async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      return await _flogDao.getAllSortedByFilter(
          filters: Filters.generateFilters(
              dataLogsType: dataLogsType,
              logLevels: logLevels,
              startTimeInMillis: startTimeInMillis,
              endTimeInMillis: endTimeInMillis,
              filterType: filterType));
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// getAllLogsByCustomFilter
  ///
  /// This will return the list of logs stored based on the custom filters provided
  /// by the user
  static Future<List<Log>> getAllLogsByCustomFilter(
      {List<Filter> filters}) async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      return await _flogDao.getAllSortedByFilter(filters: filters);
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// clearLogs
  ///
  /// This will clear all the logs stored in database
  static clearLogs() {
    _flogDao.deleteAll();
    print("Logs Cleared!");
  }

  /// deleteAllLogsByFilter
  ///
  /// This will delete logs by provided filters
  static deleteAllLogsByFilter({List<Filter> filters}) async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      int deleted = await _flogDao.deleteAllLogsByFilter(filters: filters);
      print("Deleted $deleted logs");
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// applyConfigurations
  ///
  /// This will apply user provided configurations to FLogs
  static applyConfigurations(LogsConfig config) {
    _config = config;

    //check to see if encryption is enabled
    if (_config.encryptionEnabled) {
      //check to see if encryption key is provided
      if (_config.encryptionKey.isEmpty) {
        throw new Exception(Constants.EXCEPTION_NULL_KEY);
      }
    }
  }

  /// getDefaultConfigurations
  ///
  /// Returns the default configuration
  static LogsConfig getDefaultConfigurations() {
    assert(_config != null);
    return _config;
  }

  //Private Methods:------------------------------------------------------------
  /// _logThis
  ///
  /// Logs 'String' data along with class & function name to hourly based file with formatted timestamps.
  ///
  /// @param className    the class name
  /// @param methodName the method name
  /// @param text         the text
  /// @param type         the type
  static void _logThis(
      String className,
      String methodName,
      String text,
      LogLevel type,
      Exception exception,
      String dataLogType,
      StackTrace stacktrace) {
    assert(text != null);
    assert(type != null);

    //check to see if className is not provided
    //then its already been taken from calling class
    if (className == null) {
      className = Trace.current().frames[2].member.split(".")[0];
    }

    //check to see if methodName is not provided
    //then its already been taken from calling class
    if (methodName == null) {
      methodName = Trace.current().frames[2].member.split(".")[1];
    }

    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      //creating log object
      Log log = Log(
        className: className,
        methodName: methodName,
        text: text,
        logLevel: type,
        dataLogType: dataLogType,
        exception: exception.toString(),
        timestamp: DateTimeUtils.getCurrentTimestamp(_config),
        timeInMillis: DateTimeUtils.getCurrentTimeInMillis(),
        stacktrace: stacktrace.toString(),
      );

      //writing it to DB
      _writeLogs(log);
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// _getAllLogs
  ///
  /// This will return the list of logs stored in database
  static Future<List<Log>> _getAllLogs() async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      return await _flogDao.getAllLogs();
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// _getAllSortedByFilter
  ///
  /// This will return the list of logs sorted by provided filters
  static Future<List<Log>> _getAllSortedByFilter({List<Filter> filters}) async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      return await _flogDao.getAllSortedByFilter(filters: filters);
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// _writeLogs
  ///
  /// This will write logs to local database
  static _writeLogs(Log log) async {
    //check to see if user provides a valid configuration and logs are enabled
    //if not then don't do anything
    if (_isLogsConfigValid()) {
      // skip write logs when log level is to low or
      // active log level is not in enabled log levels
      if (LogLevel.values.indexOf(_config.activeLogLevel) <=
              LogLevel.values.indexOf(log.logLevel) &&
          _config.logLevelsEnabled.contains(_config.activeLogLevel)) {
        await _flogDao.insert(log);

        //check to see if logcat debugging is enabled
        if (_config.isDebuggable) {
          print(Formatter.format(log, _config));
        }
      }
    } else {
      throw new Exception(Constants.EXCEPTION_NOT_INIT);
    }
  }

  /// _isLogsConfigValid
  ///
  /// This will check if user provided any configuration and logs are enabled
  /// if yes, then it will return true
  /// else it will return false
  static _isLogsConfigValid() {
    return _config != null && _config.isLogsEnabled;
  }
}
