import 'package:erp_domain/erp_domain.dart';

abstract interface class ProjectStore {
  Future<void> saveQuotation({
    required QuotationHeader header,
    required List<QuotationLine> lines,
  });

  Future<QuotationHeader?> getQuotationHeader(String id);

  Future<List<QuotationLine>> getQuotationLines(String quotationId);

  Future<List<QuotationHeader>> listQuotations(String organizationId);

  Future<void> saveProject(SolarProject project);

  Future<SolarProject?> getProject(String id);

  Future<List<SolarProject>> listProjects(String organizationId);

  Future<void> saveMaterialIssue({
    required ProjectMaterialIssue issue,
  });

  Future<List<ProjectMaterialIssue>> getMaterialIssues(String projectId);
}
