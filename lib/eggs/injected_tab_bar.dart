import 'package:parabeac_core/controllers/main_info.dart';

import 'package:parabeac_core/generation/generators/pb_generator.dart';
import 'package:parabeac_core/generation/generators/plugins/pb_plugin_node.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/interfaces/pb_inherited_intermediate.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/interfaces/pb_injected_intermediate.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/subclasses/pb_intermediate_node.dart';
import 'package:parabeac_core/interpret_and_optimize/helpers/align_strategy.dart';
import 'package:parabeac_core/interpret_and_optimize/helpers/pb_context.dart';
import 'package:parabeac_core/interpret_and_optimize/helpers/pb_intermediate_node_tree.dart';
import 'dart:math';

import 'injected_tab.dart';

class InjectedTabBar extends PBEgg implements PBInjectedIntermediate {
  @override
  String semanticName = '<tabbar>';

  // List<PBIntermediateNode> get tabs => getAllAtrributeNamed('tabs');

  @override
  AlignStrategy alignStrategy = NoAlignment();

  InjectedTabBar(
    String UUID,
    Rectangle frame,
    String name,
  ) : super(UUID, frame, name) {
    generator = PBTabBarGenerator();
  }

  @override
  String getAttributeNameOf(PBIntermediateNode node) {
    if (node is PBInheritedIntermediate) {
      if (node.name.contains('<tab>')) {
        assert(node is! Tab, 'node should be a Tab');
        return 'tab';
        // node.attributeName = 'tab';
        // tree.addEdges(AITVertex(this), [AITVertex(node)]);
      }
    }

    if (node is Tab) {
      return 'tab';
      // node.attributeName = 'tab';
      // tree.addEdges(AITVertex(this), [AITVertex(node)]);
    }
    return super.getAttributeNameOf(node);
  }

  @override
  List<PBIntermediateNode> layoutInstruction(List<PBIntermediateNode> layer) {}

  @override
  PBEgg generatePluginNode(Rectangle frame, PBIntermediateNode originalRef,
      PBIntermediateTree tree) {
    var originalChildren = tree.childrenOf(originalRef);
    var tabbar = InjectedTabBar(
      originalRef.UUID,
      frame,
      originalRef.name,
    );
    tree.addEdges(AITVertex(tabbar),
        originalChildren.map((child) => AITVertex(child)).toList());

    return tabbar;
  }

  @override
  void extractInformation(PBIntermediateNode incomingNode) {
    // TODO: implement extractInformation
  }
}

class PBTabBarGenerator extends PBGenerator {
  PBTabBarGenerator() : super();

  @override
  String generate(PBIntermediateNode source, PBContext context) {
    // generatorContext.sizingContext = SizingValueContext.PointValue;
    if (source is InjectedTabBar) {
      // var tabs = source.tabs;
      var tabs = source.getAllAtrributeNamed(context.tree, 'tabs');

      var buffer = StringBuffer();
      buffer.write('BottomNavigationBar(');
      buffer.write('type: BottomNavigationBarType.fixed,');
      try {
        buffer.write('items:[');
        for (var i = 0; i < tabs.length; i++) {
          var tabChildren = context.tree.childrenOf(tabs[i]);
          buffer.write('BottomNavigationBarItem(');
          var res =
              context.generationManager.generate(tabChildren.first, context);
          buffer.write('icon: $res,');
          buffer.write('title: Text(""),');
          buffer.write('),');
        }
      } catch (e, stackTrace) {
        MainInfo().sentry.captureException(
              exception: e,
              stackTrace: stackTrace,
            );
        buffer.write('),');
      }
      buffer.write('],');
      buffer.write(')');
      return buffer.toString();
    }
  }
}
