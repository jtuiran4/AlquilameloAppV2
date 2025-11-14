import 'package:get/get.dart';
import 'package:alquilamelo_app/features/agents/presentation/controllers/agent_inquiries_controller.dart';

class AgentInquiriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentInquiriesController>(() => AgentInquiriesController());
  }
}
