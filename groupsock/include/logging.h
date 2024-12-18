#define LOG_VAR_INT(var) log_variable(#var, var, __FILE__, __LINE__)

#ifdef __cplusplus
extern "C" {
#endif

void log_variable(const char* var_name, int value, const char* file, int line);

#ifdef __cplusplus
}
#endif
