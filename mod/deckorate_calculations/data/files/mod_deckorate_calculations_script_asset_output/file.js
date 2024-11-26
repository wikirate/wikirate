// calculator.js.coffee
(function() {
  var _calculate, _calculateAll;

  deckorate._regionLookup = function(region, field) {
    var entry, map;
    map = deckorate.region || {};
    entry = map[region];
    if (entry) {
      return entry[field];
    }
  };

  deckorate._addFormulaFunctions = function(context) {
    var i, key, len, ref, results, source;
    ref = [deckorate.calculator, formulajs];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      source = ref[i];
      results.push((function() {
        var j, len1, ref1, results1;
        ref1 = Object.keys(source);
        results1 = [];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          key = ref1[j];
          results1.push(context[key] = source[key]);
        }
        return results1;
      })());
    }
    return results;
  };

  deckorate.calculator = {
    iloRegion: function(region) {
      return deckorate._regionLookup(region, "ilo_region");
    },
    country: function(region) {
      return deckorate._regionLookup(region, "country");
    },
    isKnown: function(answer) {
      return answer !== "Unknown";
    },
    numKnown: function(list) {
      return list.filter(isKnown).length;
    },
    anyKnown: function(list) {
      return list.find(isKnown);
    }
  };

  _calculateAll = function(obj) {
    var key, r, val;
    r = {};
    for (key in obj) {
      val = obj[key];
      r[key] = _calculate(val);
    }
    return r;
  };

  _calculate = function(inputList) {
    return deckorate._addFormulaFunctions(this);
  };

}).call(this);

// variables.js.coffee
(function() {
  $.extend(deckorate, {
    VariablesEditor: (function() {
      function _Class(el) {
        this.ed = $(el).closest("._variablesEditor");
      }

      _Class.prototype.form = function() {
        return this.ed.closest("form");
      };

      _Class.prototype.submitButton = function() {
        return this.form().find(".submit-button");
      };

      _Class.prototype.variableClass = function() {
        return deckorate.Variable;
      };

      _Class.prototype.variables = function() {
        var ed, i, item, klass, len, ref, results;
        klass = this.variableClass();
        ed = this.ed;
        ref = ed.find("._filtered-list-item");
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          item = ref[i];
          results.push(new klass(item));
        }
        return results;
      };

      _Class.prototype.hashList = function() {
        var i, len, ref, results, v;
        ref = this.variables();
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          v = ref[i];
          results.push(Object.assign({}, v.hash()));
        }
        return results;
      };

      _Class.prototype.json = function() {
        return JSON.stringify(this.hashList());
      };

      _Class.prototype.variable = function(el) {
        return $(el).closest("._filtered-list-item");
      };

      _Class.prototype.removeVariable = function(el) {
        return this.variable(el).remove();
      };

      return _Class;

    })(),
    Variable: (function() {
      function _Class(item) {
        this.row = $(item);
      }

      _Class.prototype.metricId = function() {
        return this.row.find(".TYPE-metric.thumbnail").data("cardId");
      };

      return _Class;

    })()
  });

}).call(this);

// formula_variables.js.coffee
(function() {
  var FormulaVariable, OptionEditor, variabler,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  decko.editors.content['._variablesEditor'] = function() {
    return variabler(this).json();
  };

  $(window).ready(function() {
    $('body').on("click", "._remove-variable", function() {
      return variabler(this).removeVariable(this);
    });
    $('body').on("change", "._options-scheme", function() {
      return variabler(this).setOptions($(this).val());
    });
    $('body').on("click", "._edit-variable-options", function() {
      return variabler(this).editVariableOptions(this);
    });
    $('body').on("click", "._update-formula-options", function() {
      $(this).closest("._formula-options-template").data("opEd").update();
      return $(this).closest('.modal').modal("hide");
    });
    $('body').on("change", "._custom-formula-option", function() {
      return $(this).closest(".vo-radio").find("input[type=radio]").prop("checked", true);
    });
    $('body').on("change keyup paste", "._variablesEditor ._sample-value", function() {
      return variabler(this).runSampleCalculation();
    });
    $('body').on("focus", "._variable-name", function() {
      return this.previousValue = $(this).val();
    });
    return $('body').on("keyup", "._variable-name", function() {
      var newval, previous;
      previous = this.previousValue;
      newval = $(this).val();
      console.log("updating value from " + previous + " to " + newval);
      variabler(this).updateVariableNameInFormula(previous, newval);
      return this.previousValue = newval;
    });
  });

  decko.slot.ready(function(slot) {
    var ed;
    ed = slot.find("> form ._formulaVariablesEditor");
    if (ed.length > 0) {
      variabler(ed).initOptions();
      return ed.closest(".modal-dialog").addClass("modal-full");
    }
  });

  decko.itemAdded(function(el) {
    var v, ve;
    if (el.hasClass("_variable-row")) {
      ve = variabler(el);
      ve.setOptions($("._options-scheme").val());
      ve.updateFormulaInputs();
      v = new FormulaVariable(el);
      return v.autoName(ve.variableNames());
    }
  });

  variabler = function(el) {
    return new deckorate.FormulaVariablesEditor(el);
  };

  deckorate.FormulaVariablesEditor = (function(superClass) {
    extend(FormulaVariablesEditor, superClass);

    function FormulaVariablesEditor() {
      return FormulaVariablesEditor.__super__.constructor.apply(this, arguments);
    }

    FormulaVariablesEditor.prototype.variableClass = function() {
      return FormulaVariable;
    };

    FormulaVariablesEditor.prototype.form = function() {
      return this.ed.closest("form");
    };

    FormulaVariablesEditor.prototype.variableNames = function() {
      var i, len, ref, results, v;
      ref = this.variables();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        v = ref[i];
        results.push(v.variableName().val());
      }
      return results;
    };

    FormulaVariablesEditor.prototype.variableValues = function() {
      var i, len, ref, results, v;
      ref = this.variables();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        v = ref[i];
        results.push(v.sampleInputVal());
      }
      return results;
    };

    FormulaVariablesEditor.prototype.removeVariable = function(el) {
      FormulaVariablesEditor.__super__.removeVariable.call(this, el);
      return this.updateFormulaInputs();
    };

    FormulaVariablesEditor.prototype.detectOptionsScheme = function() {
      if (!this.variables().some(function(v) {
        return !v.allResearchedOptions();
      })) {
        return "all_researched";
      } else if (!this.variables().some(function(v) {
        return !v.anyResearchedOptions();
      })) {
        return "any_researched";
      } else {
        return "custom";
      }
    };

    FormulaVariablesEditor.prototype.initOptions = function() {
      var i, len, ref, scheme, schemeSelect, v;
      ref = this.variables();
      for (i = 0, len = ref.length; i < len; i++) {
        v = ref[i];
        v.initOptions();
      }
      scheme = this.detectOptionsScheme();
      schemeSelect = this.ed.find("select._options-scheme");
      schemeSelect.val(scheme);
      schemeSelect.trigger("change");
      this.toggleOptionEdit(scheme);
      return this.updateFormulaInputs();
    };

    FormulaVariablesEditor.prototype.toggleOptionEdit = function(scheme) {
      return $("._edit-variable-options").toggle(scheme === "custom");
    };

    FormulaVariablesEditor.prototype.setOptions = function(scheme) {
      var i, len, options, ref, v;
      this.toggleOptionEdit(scheme);
      if (scheme !== "custom") {
        options = this.optionsFor(scheme);
        ref = this.variables();
        for (i = 0, len = ref.length; i < len; i++) {
          v = ref[i];
          v.setOptions(options);
        }
      }
      return this.updateFormulaInputs();
    };

    FormulaVariablesEditor.prototype.optionsFor = function(scheme) {
      switch (scheme) {
        case "all_researched":
          return {};
        case "any_researched":
          return {
            unknown: "Unknown",
            not_researched: "Unknown"
          };
      }
    };

    FormulaVariablesEditor.prototype.editVariableOptions = function(el) {
      var opEd, v;
      opEd = this.ed.find("._formula-options-template").clone();
      v = new FormulaVariable(this.variable(el));
      return v.initOptionEditor(opEd);
    };

    FormulaVariablesEditor.prototype.formulaEditor = function() {
      var el;
      el = this.form().find("._formula-editor");
      if (!(el.length > 0)) {
        return;
      }
      return new decko.FormulaEditor(el);
    };

    FormulaVariablesEditor.prototype.runSampleCalculation = function() {
      return this.formulaEditor().runVisibleCalculation();
    };

    FormulaVariablesEditor.prototype.updateVariableNameInFormula = function(oldval, newval) {
      var formEd;
      if (newval !== oldval && (formEd = this.formulaEditor())) {
        return formEd.updateVariableName(oldval, newval);
      }
    };

    FormulaVariablesEditor.prototype.updateFormulaInputs = function() {
      var formEd;
      if (!(formEd = this.formulaEditor())) {
        return;
      }
      return formEd.requestInputs(this.json());
    };

    FormulaVariablesEditor.prototype.showInputs = function(inputs) {
      var i, index, len, ref, results, v;
      inputs || (inputs = []);
      ref = this.variables();
      results = [];
      for (index = i = 0, len = ref.length; i < len; index = ++i) {
        v = ref[index];
        results.push(v.sampleInput().val(JSON.stringify(inputs[index])));
      }
      return results;
    };

    return FormulaVariablesEditor;

  })(deckorate.VariablesEditor);

  OptionEditor = (function() {
    function OptionEditor(opEd, variable) {
      this.opEd = opEd;
      this.variable = variable;
      this.opEd.data("opEd", this);
    }

    OptionEditor.prototype.init = function() {
      this.opEd.showAsModal(this.variable.row);
      this.opEd.closest(".modal-dialog").addClass("modal-lg");
      return this.interpret();
    };

    OptionEditor.prototype.interpret = function() {
      var opts;
      opts = this.variable.options();
      this.setRadioVal("unknown", opts.unknown || "result_unknown");
      this.setRadioVal("not_researched", opts.not_researched || "no_result");
      this.setTextVal("year", opts.year);
      return this.setTextVal("company", opts.company);
    };

    OptionEditor.prototype.input = function(field) {
      return this.opEd.find("[name=vo-" + field + "]");
    };

    OptionEditor.prototype.textVal = function(field) {
      return this.input(field).val();
    };

    OptionEditor.prototype.setTextVal = function(field, val) {
      return this.input(field).val(val);
    };

    OptionEditor.prototype.radioVal = function(field) {
      var val;
      val = this.input(field).filter(":checked").val();
      if (val === "custom") {
        return this.textVal(field + "-custom");
      } else {
        return val;
      }
    };

    OptionEditor.prototype.setRadioVal = function(field, val) {
      var radioForVal, radios;
      radios = this.input(field);
      radioForVal = radios.filter("[value=" + val + "]");
      if (radioForVal.length === 0) {
        radioForVal = radios.filter("[value=custom]");
        this.setTextVal(field + "-custom", val);
      }
      return radioForVal.prop("checked", true);
    };

    OptionEditor.prototype.hash = function() {
      return {
        unknown: this.radioVal("unknown"),
        not_researched: this.radioVal("not_researched"),
        year: this.textVal("year"),
        company: this.textVal("company")
      };
    };

    OptionEditor.prototype.update = function() {
      this.variable.setOptions(this.hash());
      return variabler(this.variable.row).updateFormulaInputs();
    };

    return OptionEditor;

  })();

  FormulaVariable = (function(superClass) {
    extend(FormulaVariable, superClass);

    function FormulaVariable() {
      return FormulaVariable.__super__.constructor.apply(this, arguments);
    }

    FormulaVariable.prototype.variableName = function() {
      return this.row.find("._variable-name");
    };

    FormulaVariable.prototype.hash = function() {
      var hash;
      hash = Object.assign({}, this.options());
      hash.metric = "~" + (this.metricId());
      hash.name = this.variableName().val();
      return hash;
    };

    FormulaVariable.prototype.options = function() {
      return this.optionsList().data("options");
    };

    FormulaVariable.prototype.optionsList = function() {
      return this.row.find("._formula_options");
    };

    FormulaVariable.prototype.initOptionEditor = function(opEd) {
      this.optionEditor = new OptionEditor(opEd, this);
      return this.optionEditor.init();
    };

    FormulaVariable.prototype.initOptions = function() {
      this.setOptions(this.options());
      if (!this.variableName().val()) {
        return this.autoName([]);
      }
    };

    FormulaVariable.prototype.setOptions = function(options) {
      this.cleanOptions(options);
      this.optionsList().data("options", options);
      return this.publishOptions();
    };

    FormulaVariable.prototype.cleanOptions = function(options) {
      var i, key, len, ref, results;
      if (options.unknown === "result_unknown") {
        delete options.unknown;
      }
      if (options.not_researched === "no_result") {
        delete options.not_researched;
      }
      ref = Object.keys(options);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        if (!options[key]) {
          results.push(delete options[key]);
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    FormulaVariable.prototype.publishOptions = function() {
      var key, list, ref, results, value;
      list = this.optionsList();
      list.children().remove();
      if (this.allResearchedOptions()) {
        return list.html("<div class='text-muted'>(default)</div>");
      } else {
        ref = this.options();
        results = [];
        for (key in ref) {
          value = ref[key];
          results.push(list.append("<div class='small'><label>" + key + "</label>: " + value + "</div>"));
        }
        return results;
      }
    };

    FormulaVariable.prototype.optionsLength = function() {
      return Object.keys(this.options()).length;
    };

    FormulaVariable.prototype.allResearchedOptions = function() {
      return this.optionsLength() === 0;
    };

    FormulaVariable.prototype.anyResearchedOptions = function() {
      var opts;
      opts = this.options();
      return this.optionsLength() === 2 && opts.not_researched === "Unknown" && opts.unknown === "Unknown";
    };

    FormulaVariable.prototype.sampleInput = function() {
      return this.row.find("._sample-value");
    };

    FormulaVariable.prototype.sampleInputVal = function() {
      var raw;
      raw = this.sampleInput().val();
      if (raw) {
        return $.parseJSON(raw);
      } else {
        return "";
      }
    };

    FormulaVariable.prototype.autoName = function(taken) {
      var candidate, name, name_parts, x;
      name_parts = this.row.find(".thumbnail-title .card-title").html().split(" ");
      name = name_parts.find(function(candidate) {
        return !taken.includes(candidate);
      });
      x = 1;
      while (!name) {
        candidate = "m" + x;
        if (taken.includes(candidate)) {
          x += 1;
        } else {
          name = candidate;
        }
      }
      return this.variableName().val(name);
    };

    return FormulaVariable;

  })(deckorate.Variable);

}).call(this);

// metric_formula.js.coffee
(function() {
  var drCalculator, dumbEval, formEd, getRegionData, initFormulaEditor;

  $(window).ready(function() {
    return $('body').on("click", "._formula-input-links a", function() {
      return formEd(this).showInputs($(this).data("inputIndex"));
    });
  });

  decko.slot.ready(function(slot) {
    var edEl;
    edEl = slot.find("> form ._formula-editor");
    if (edEl[0] && !edEl.data("editorInitialized")) {
      setTimeout((function() {
        return initFormulaEditor();
      }), 20);
      return edEl.data("editorInitialized", true);
    }
  });

  initFormulaEditor = function() {
    var cm, textarea;
    textarea = $("._formula-editor .codemirror-editor-textarea");
    if (!(cm = textarea.data("codeMirror"))) {
      return;
    }
    getRegionData();
    textarea.closest(".modal-dialog").addClass("modal-full");
    return cm.on("changes", function() {
      var fe;
      fe = formEd(textarea);
      fe.runVisibleCalculation();
      return fe.runCalculations();
    });
  };

  getRegionData = function() {
    return $.get(decko.path("mod/wikirate_companies/region.json"), function(json) {
      return deckorate.region = json;
    });
  };

  formEd = function(el) {
    return new decko.FormulaEditor(el);
  };

  decko.FormulaEditor = (function() {
    function FormulaEditor(el) {
      this.ed = $(el).closest("._formula-editor");
      this.area = this.ed.find(".codemirror-editor-textarea").data("codeMirror");
      this.slot = this.ed.slot();
      this.form = this.ed.closest("form");
      this.isScore = this.slot.find("._scoreVariablesEditor").length > 0;
    }

    FormulaEditor.prototype.requestInputs = function(variables) {
      var f;
      f = this;
      return $.ajax({
        url: decko.path("?" + ($.param(this.requestInputsParams(variables)))),
        success: function(json) {
          return f.updateInputs(json);
        },
        error: function(_jqXHR, textStatus) {
          return f.slot.notify("error: " + textStatus, "error");
        }
      });
    };

    FormulaEditor.prototype.requestInputsParams = function(variables) {
      return {
        assign: true,
        view: "input_lists",
        format: "json",
        card: {
          type: ":metric",
          fields: {
            ":variables": variables,
            ":metric_type": "Formula"
          }
        }
      };
    };

    FormulaEditor.prototype.updateInputs = function(inputs) {
      this.ed.data("inputs", inputs);
      this.showInputs(0);
      this.runCalculations();
      return this.updateAnswers();
    };

    FormulaEditor.prototype.inputs = function() {
      return this.ed.data("inputs");
    };

    FormulaEditor.prototype.updateAnswers = function() {
      var i;
      i = this.inputs();
      $("._ab-total").html(i.total);
      $("._ab-result-unknown").toggle(i.unknown > 0);
      $("._ab-result-unknown-count").html(i.unknown);
      return $("._ab-sample-size").html(i.sample.length);
    };

    FormulaEditor.prototype.variableEditor = function() {
      var klass, ved;
      ved = this.form.find("._variablesEditor");
      klass = this.isScore && "ScoreVariableEditor" || "FormulaVariablesEditor";
      return new deckorate[klass](ved);
    };

    FormulaEditor.prototype.showInputs = function(index) {
      this.variableEditor().showInputs(this.inputs().sample[index]);
      return this.runVisibleCalculation();
    };

    FormulaEditor.prototype.runCalculations = function() {
      var calc, results;
      calc = this.calculator();
      results = {
        known: [],
        unknown: [],
        error: []
      };
      this.submitButton(false);
      if (calc._formula) {
        this.runEachCalculation(calc, results);
        if (results["error"].length === 0) {
          this.submitButton(true);
        }
      }
      return this.publishResults(results);
    };

    FormulaEditor.prototype.runEachCalculation = function(calc, results) {
      var e, index, inputList, j, key, len, message, r, ref, results1;
      ref = this.inputs().sample;
      results1 = [];
      for (index = j = 0, len = ref.length; j < len; index = ++j) {
        inputList = ref[index];
        key = "known";
        message = "";
        try {
          r = calc._simple_run(inputList);
          if (r === "Unknown") {
            key = "unknown";
          } else if (typeof r === "number") {
            if (isNaN(r) || !isFinite(r)) {
              key = "error";
            }
          } else if (!r) {
            key = "error";
          }
          message = r;
        } catch (error) {
          e = error;
          key = "error";
          message = e.message;
        }
        results1.push(results[key].push({
          index: index,
          message: message
        }));
      }
      return results1;
    };

    FormulaEditor.prototype.submitButton = function(enabled) {
      return this.form.find(".submit-button").prop("disabled", !enabled);
    };

    FormulaEditor.prototype.publishResults = function(results) {
      var group, j, key, len, link, linkdiv, object, ref, results1;
      ref = Object.keys(results);
      results1 = [];
      for (j = 0, len = ref.length; j < len; j++) {
        key = ref[j];
        group = $("._ab-sample-" + key);
        group.find("._result-count").html(results[key].length);
        linkdiv = group.find("._formula-input-links");
        linkdiv.html("");
        results1.push((function() {
          var k, len1, ref1, results2;
          ref1 = results[key];
          results2 = [];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            object = ref1[k];
            link = $('<a><i></i></a>');
            link.data("inputIndex", object.index);
            link.attr("title", object.message);
            results2.push(linkdiv.append(link));
          }
          return results2;
        })());
      }
      return results1;
    };

    FormulaEditor.prototype.calculator = function() {
      return new drCalculator(this.rawFormula(), this.variableEditor().variableNames(), this.ed);
    };

    FormulaEditor.prototype.runVisibleCalculation = function() {
      var result;
      result = this.calculator()._run(this.variableEditor().variableValues());
      return this.ed.find("._sample-result-value").html(result);
    };

    FormulaEditor.prototype.rawFormula = function() {
      if (this.area) {
        return this.area.getValue();
      } else {
        return $("._formula-editor .codemirror-editor-textarea").val();
      }
    };

    FormulaEditor.prototype.updateVariableName = function(oldval, newval) {
      var newFormula, re;
      if (!oldval || oldval === newval) {
        return;
      }
      re = new RegExp(oldval, "g");
      newFormula = this.rawFormula().replace(re, newval);
      return this.area.getDoc().setValue(newFormula);
    };

    return FormulaEditor;

  })();

  drCalculator = (function() {
    function drCalculator(_rawFormula, _variableNames, _ed) {
      this._rawFormula = _rawFormula;
      this._variableNames = _variableNames;
      this._ed = _ed;
      this._formula = this._compile();
    }

    drCalculator.prototype._run = function(inputList) {
      var e;
      if (!this._formula) {
        return "invalid formula";
      }
      try {
        return this._simple_run(inputList);
      } catch (error) {
        e = error;
        return e.message;
      }
    };

    drCalculator.prototype._simple_run = function(inputList) {
      return dumbEval(this._formula, inputList);
    };

    drCalculator.prototype._compile = function() {
      var f;
      f = this._formulaJS();
      if (!f.trim()) {
        return "";
      }
      return this._setVariablesJS() + "\n" + f;
    };

    drCalculator.prototype._setVariablesJS = function() {
      var index, j, len, name, ref, string;
      string = "";
      ref = this._variableNames;
      for (index = j = 0, len = ref.length; j < len; index = ++j) {
        name = ref[index];
        string += name + " = inputList[" + index + "];\n";
      }
      return string;
    };

    drCalculator.prototype._formulaJS = function() {
      var e, raw;
      try {
        raw = CoffeeScript.compile(this._rawFormula, {
          bare: true
        });
        this._publish(raw, "");
        return raw;
      } catch (error) {
        e = error;
        this._publish(e, e);
        return "";
      }
    };

    drCalculator.prototype._publish = function(js, notify) {
      this._ed.find("._formula-as-javascript").html(js);
      return this._ed.slot().notify(notify);
    };

    return drCalculator;

  })();

  dumbEval = function(formula, inputList) {
    deckorate._addFormulaFunctions(this);
    return eval(formula);
  };

}).call(this);

// rubric.js.coffee
(function() {
  var pairsEditorHash, variableMetricRows, variabler,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  decko.editors.content['.pairs-editor'] = function() {
    return JSON.stringify(pairsEditorHash(this));
  };

  decko.slot.ready(function(slot) {
    var ed;
    ed = slot.find("> form ._scoreVariablesEditor");
    if (ed.length > 0) {
      return variabler(ed).updateFormulaInputs();
    }
  });

  variabler = function(el) {
    return new deckorate.ScoreVariableEditor(el);
  };

  pairsEditorHash = function(table) {
    var hash;
    hash = {};
    variableMetricRows(table).each(function() {
      var cols, key;
      cols = $(this).find('td');
      if ((key = $(cols[0]).data('key'))) {
        return hash[key] = $(cols[1]).find('input').val();
      }
    });
    return hash;
  };

  variableMetricRows = function(table) {
    return table.find("tbody tr");
  };

  deckorate.ScoreVariableEditor = (function(superClass) {
    extend(ScoreVariableEditor, superClass);

    function ScoreVariableEditor() {
      return ScoreVariableEditor.__super__.constructor.apply(this, arguments);
    }

    ScoreVariableEditor.prototype.variableNames = function() {
      return ["answer"];
    };

    ScoreVariableEditor.prototype.sampleValueInput = function() {
      return this.ed.find("._sample-value");
    };

    ScoreVariableEditor.prototype.variableValues = function() {
      return [$.parseJSON(this.sampleValueInput().val())];
    };

    ScoreVariableEditor.prototype.hashList = function() {
      return this.ed.data("variablesJson");
    };

    ScoreVariableEditor.prototype.showInputs = function(inputs) {
      return this.sampleValueInput().val(inputs[0]);
    };

    return ScoreVariableEditor;

  })(deckorate.FormulaVariablesEditor);

}).call(this);

// wikirating.js.coffee
(function() {
  var WeightedVariable, WeightsEditor, weighter,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  decko.editors.content['.wikiRating-editor'] = function() {
    return weighter(this).json();
  };

  decko.slot.ready(function() {
    var we;
    $('.metric-weight input').on('keyup', function() {
      return weighter(this).checkEqualization();
    });
    $('#equalizer').on('click', function() {
      if ($(this).prop('checked') === true) {
        return weighter(this).equalize();
      }
    });
    we = $("._wikiRating-editor");
    if (we.length > 0) {
      return weighter(we).validate();
    }
  });

  decko.itemsAdded(function(slot) {
    var ed;
    ed = slot.find(".wikiRating-editor");
    if (ed[0]) {
      return weighter(ed).validate();
    }
  });

  $(window).ready(function() {
    $('body').on('input', '.metric-weight input', function() {
      return weighter(this).validate();
    });
    return $('body').on("click", "._remove-weight", function() {
      return weighter(this).removeVariable(this);
    });
  });

  weighter = function(el) {
    return new WeightsEditor(el);
  };

  WeightsEditor = (function(superClass) {
    extend(WeightsEditor, superClass);

    function WeightsEditor() {
      return WeightsEditor.__super__.constructor.apply(this, arguments);
    }

    WeightsEditor.prototype.variableClass = function() {
      return WeightedVariable;
    };

    WeightsEditor.prototype.weights = function() {
      var j, len, ref, results, v;
      ref = this.variables();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        v = ref[j];
        results.push(v.weight());
      }
      return results;
    };

    WeightsEditor.prototype.checkEqualization = function() {
      return $('#equalizer').prop('checked', this.areEqual());
    };

    WeightsEditor.prototype.areEqual = function() {
      return this.weights().every((function(_this) {
        return function(val, i, arr) {
          return val === arr[0];
        };
      })(this)) === true;
    };

    WeightsEditor.prototype.removeVariable = function(el) {
      WeightsEditor.__super__.removeVariable.call(this, el);
      return this.equalize();
    };

    WeightsEditor.prototype.equalize = function() {
      var j, len, v, vars, weight;
      vars = this.variables();
      weight = (100 / vars.length).toFixed(2);
      for (j = 0, len = vars.length; j < len; j++) {
        v = vars[j];
        v.setWeight(weight);
      }
      return this.validate();
    };

    WeightsEditor.prototype.validate = function() {
      var t, valid;
      t = this.total();
      valid = t > 99.90 && t <= 100.09 && !this.invalidWeight();
      return this.submitButton().prop("disabled", !valid);
    };

    WeightsEditor.prototype.invalidWeight = function() {
      return this.variables().find(function(v) {
        return v.isInvalid();
      });
    };

    WeightsEditor.prototype.total = function() {
      var t;
      t = (this.weights().reduce((function(a, b) {
        return a + b;
      }), 0)).toFixed(2);
      this.ed.find('.weight-sum').val(t);
      return t;
    };

    return WeightsEditor;

  })(deckorate.VariablesEditor);

  WeightedVariable = (function(superClass) {
    extend(WeightedVariable, superClass);

    function WeightedVariable() {
      return WeightedVariable.__super__.constructor.apply(this, arguments);
    }

    WeightedVariable.prototype.hash = function() {
      return {
        metric: "~" + (this.metricId()),
        weight: this.weight()
      };
    };

    WeightedVariable.prototype.weightInput = function() {
      return this.row.find(".metric-weight input");
    };

    WeightedVariable.prototype.weight = function() {
      return parseFloat(this.weightInput().val());
    };

    WeightedVariable.prototype.setWeight = function(val) {
      return this.weightInput().val(val);
    };

    WeightedVariable.prototype.isInvalid = function() {
      var w;
      w = this.weight();
      return isNaN(w) || w <= 0 || w > 100;
    };

    return WeightedVariable;

  })(deckorate.Variable);

}).call(this);

// formula.js
/* @formulajs/formulajs v3.0.0 */
function _typeof(n){return _typeof="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(n){return typeof n}:function(n){return n&&"function"==typeof Symbol&&n.constructor===Symbol&&n!==Symbol.prototype?"symbol":typeof n},_typeof(n)}!function(n,r){"object"===("undefined"==typeof exports?"undefined":_typeof(exports))&&"undefined"!=typeof module?r(exports):"function"==typeof define&&define.amd?define(["exports"],r):r((n="undefined"!=typeof globalThis?globalThis:n||self).formulajs={})}(this,(function(n){"use strict";var r=new Error("#NULL!"),t=new Error("#DIV/0!"),e=new Error("#VALUE!"),o=new Error("#REF!"),u=new Error("#NAME?"),i=new Error("#NUM!"),a=new Error("#N/A"),f=new Error("#ERROR!"),c=new Error("#GETTING_DATA");function l(n){return n&&n.reduce?n.reduce((function(n,r){var t=Array.isArray(n),e=Array.isArray(r);return t&&e?n.concat(r):t?(n.push(r),n):e?[n].concat(r):[n,r]})):n}function s(n){if(!n)return!1;for(var r=0;r<n.length;++r)if(Array.isArray(n[r]))return!1;return!0}function h(){for(var n=g.apply(null,arguments);!s(n);)n=l(n);return n}function g(n){var r=[];return D(n,(function(n){r.push(n)})),r}function v(){var n=h.apply(null,arguments);return n.filter((function(n){return"number"==typeof n}))}function p(n){var r=1e14;return Math.round(n*r)/r}function m(n){if("boolean"==typeof n)return n;if(n instanceof Error)return n;if("number"==typeof n)return 0!==n;if("string"==typeof n){var r=n.toUpperCase();if("TRUE"===r)return!0;if("FALSE"===r)return!1}return n instanceof Date&&!isNaN(n)||e}function d(n){return n instanceof Error?n:null==n||""===n?0:("boolean"==typeof n&&(n=+n),isNaN(n)?e:parseFloat(n))}function E(n){return n instanceof Error?n:null==n?"":n.toString()}function M(n){var r,t;if(!n||0===(r=n.length))return e;for(;r--;){if(n[r]instanceof Error)return n[r];if((t=d(n[r]))instanceof Error)return t;n[r]=t}return n}function N(n){if(!isNaN(n)){if(n instanceof Date)return new Date(n);var r=parseFloat(n);return r<0||r>=2958466?i:function(n){n<60&&(n+=1);var r=Math.floor(n-25569),t=new Date(86400*r*1e3),e=n-Math.floor(n)+1e-7,o=Math.floor(86400*e),u=o%60;o-=u;var i=Math.floor(o/3600),a=Math.floor(o/60)%60,f=t.getDate(),c=t.getMonth();return n>=60&&n<61&&(f=29,c=1),new Date(t.getFullYear(),c,f,i,a,u)}(r)}return"string"!=typeof n||(n=new Date(n),isNaN(n))?e:n}function w(n){for(var r,t=n.length;t--;){if((r=N(n[t]))===e)return r;n[t]=r}return n}function I(){for(var n=0;n<arguments.length;n++)if(arguments[n]instanceof Error)return arguments[n]}function y(n){return null!=n}function b(){for(var n=arguments.length;n--;)if(arguments[n]instanceof Error)return!0;return!1}function T(){for(var n=arguments.length;n--;)if("string"==typeof arguments[n])return!0;return!1}function S(n){for(var r,t=n.length;t--;)if("number"!=typeof(r=n[t]))if(!0!==r)if(!1!==r){if("string"==typeof r){var e=d(r);e instanceof Error?n[t]=0:n[t]=e}}else n[t]=0;else n[t]=1;return n}function A(n,r){return r=r||1,n&&"function"==typeof n.slice?n.slice(r):n}function D(n,r){for(var t=-1,e=n.length;++t<e&&!1!==r(n[t],t,n););return n}var R=new Date(Date.UTC(1900,0,1)),C=[void 0,0,1,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,1,2,3,4,5,6,0],x=[[],[1,2,3,4,5,6,7],[7,1,2,3,4,5,6],[6,0,1,2,3,4,5],[],[],[],[],[],[],[],[7,1,2,3,4,5,6],[6,7,1,2,3,4,5],[5,6,7,1,2,3,4],[4,5,6,7,1,2,3],[3,4,5,6,7,1,2],[2,3,4,5,6,7,1],[1,2,3,4,5,6,7]],O=[[],[6,0],[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],void 0,void 0,void 0,[0,0],[1,1],[2,2],[3,3],[4,4],[5,5],[6,6]];function P(n){var r=new Date(n);return r.setHours(0,0,0,0),r}function L(n,r){return n=N(n),r=N(r),n instanceof Error?n:r instanceof Error?r:X(P(n))-X(P(r))}function q(n,r,t){if(t=m(t||"false"),n=N(n),r=N(r),n instanceof Error)return n;if(r instanceof Error)return r;if(t instanceof Error)return t;var e,o,u=n.getMonth(),i=r.getMonth();if(t)e=31===n.getDate()?30:n.getDate(),o=31===r.getDate()?30:r.getDate();else{var a=new Date(n.getFullYear(),u+1,0).getDate(),f=new Date(r.getFullYear(),i+1,0).getDate();e=n.getDate()===a?30:n.getDate(),r.getDate()===f?e<30?(i++,o=1):o=30:o=r.getDate()}return 360*(r.getFullYear()-n.getFullYear())+30*(i-u)+(o-e)}function U(n){if((n=N(n))instanceof Error)return n;(n=P(n)).setDate(n.getDate()+4-(n.getDay()||7));var r=new Date(n.getFullYear(),0,1);return Math.ceil(((n-r)/864e5+1)/7)}function F(n,r,t){return F.INTL(n,r,1,t)}function _(n,r,t){return _.INTL(n,r,1,t)}function V(n){return 1===new Date(n,1,29).getMonth()}function G(n,r){return Math.ceil((r-n)/1e3/60/60/24)}function k(n,r,t){if((n=N(n))instanceof Error)return n;if((r=N(r))instanceof Error)return r;t=t||0;var e=n.getDate(),o=n.getMonth()+1,u=n.getFullYear(),i=r.getDate(),a=r.getMonth()+1,f=r.getFullYear();switch(t){case 0:return 31===e&&31===i?(e=30,i=30):31===e?e=30:30===e&&31===i&&(i=30),(i+30*a+360*f-(e+30*o+360*u))/360;case 1:var c=365;if(u===f||u+1===f&&(o>a||o===a&&e>=i))return(u===f&&V(u)||function(n,r){var t=n.getFullYear(),e=new Date(t,2,1);if(V(t)&&n<e&&r>=e)return!0;var o=r.getFullYear(),u=new Date(o,2,1);return V(o)&&r>=u&&n<u}(n,r)||1===a&&29===i)&&(c=366),G(n,r)/c;var l=f-u+1,s=(new Date(f+1,0,1)-new Date(u,0,1))/1e3/60/60/24/l;return G(n,r)/s;case 2:return G(n,r)/360;case 3:return G(n,r)/365;case 4:return(i+30*a+360*f-(e+30*o+360*u))/360}}function X(n){var r=n>-22038912e5?2:1;return Math.ceil((n-R)/864e5)+r}F.INTL=function(n,r,t,o){if((n=N(n))instanceof Error)return n;if((r=N(r))instanceof Error)return r;var u=!1,i=[],a=[1,2,3,4,5,6,0],f=new RegExp("^[0|1]{7}$");if(void 0===t)t=O[1];else if("string"==typeof t&&f.test(t)){u=!0,t=t.split("");for(var c=0;c<t.length;c++)"1"===t[c]&&i.push(a[c])}else t=O[t];if(!(t instanceof Array))return e;void 0===o?o=[]:o instanceof Array||(o=[o]);for(var l=0;l<o.length;l++){var s=N(o[l]);if(s instanceof Error)return s;o[l]=s}for(var h=Math.round((r-n)/864e5)+1,g=h,v=n,p=0;p<h;p++){for(var m=(new Date).getTimezoneOffset()>0?v.getUTCDay():v.getDay(),d=u?i.includes(m):m===t[0]||m===t[1],E=0;E<o.length;E++){var M=o[E];if(M.getDate()===v.getDate()&&M.getMonth()===v.getMonth()&&M.getFullYear()===v.getFullYear()){d=!0;break}}d&&g--,v.setDate(v.getDate()+1)}return g},_.INTL=function(n,r,t,o){if((n=N(n))instanceof Error)return n;if((r=d(r))instanceof Error)return r;if(r<0)return i;if(!((t=void 0===t?O[1]:O[t])instanceof Array))return e;void 0===o?o=[]:o instanceof Array||(o=[o]);for(var u=0;u<o.length;u++){var a=N(o[u]);if(a instanceof Error)return a;o[u]=a}for(var f=0;f<r;){n.setDate(n.getDate()+1);var c=n.getDay();if(c!==t[0]&&c!==t[1]){for(var l=0;l<o.length;l++){var s=o[l];if(s.getDate()===n.getDate()&&s.getMonth()===n.getMonth()&&s.getFullYear()===n.getFullYear()){f--;break}}f++}}return n};"undefined"!=typeof globalThis?globalThis:"undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self&&self;var Y={};!function(n){var r;r=function(n){n.version="1.0.2";var r=Math;function t(n,r){for(var t=0,e=0;t<n.length;++t)e=r*e+n[t];return e}function e(n,r,t,e,o){if(0===r)return t;if(1===r)return e;for(var u=2/n,i=e,a=1;a<r;++a)i=e*a*u+o*t,t=e,e=i;return i}function o(n,r,t,o,u){return function(t,i){if(o){if(0===t)return 1==o?-1/0:1/0;if(t<0)return NaN}return 0===i?n(t):1===i?r(t):i<0?NaN:e(t,i|=0,n(t),r(t),u)}}var u,i,a,f,c,l,s,h,g,v,p,m,d,E=function(){var n=.636619772,o=[57568490574,-13362590354,651619640.7,-11214424.18,77392.33017,-184.9052456].reverse(),u=[57568490411,1029532985,9494680.718,59272.64853,267.8532712,1].reverse(),i=[1,-.001098628627,2734510407e-14,-2073370639e-15,2.093887211e-7].reverse(),a=[-.01562499995,.0001430488765,-6911147651e-15,7.621095161e-7,-9.34935152e-8].reverse();function f(e){var f=0,c=0,l=0,s=e*e;if(e<8)f=(c=t(o,s))/(l=t(u,s));else{var h=e-.785398164;c=t(i,s=64/s),l=t(a,s),f=r.sqrt(n/e)*(r.cos(h)*c-r.sin(h)*l*8/e)}return f}var c=[72362614232,-7895059235,242396853.1,-2972611.439,15704.4826,-30.16036606].reverse(),l=[144725228442,2300535178,18583304.74,99447.43394,376.9991397,1].reverse(),s=[1,.00183105,-3516396496e-14,2457520174e-15,-2.40337019e-7].reverse(),h=[.04687499995,-.0002002690873,8449199096e-15,-8.8228987e-7,1.05787412e-7].reverse();function g(e){var o=0,u=0,i=0,a=e*e,f=r.abs(e)-2.356194491;return Math.abs(e)<8?o=(u=e*t(c,a))/(i=t(l,a)):(u=t(s,a=64/a),i=t(h,a),o=r.sqrt(n/r.abs(e))*(r.cos(f)*u-r.sin(f)*i*8/r.abs(e)),e<0&&(o=-o)),o}return function n(t,o){if(o=Math.round(o),!isFinite(t))return isNaN(t)?t:0;if(o<0)return(o%2?-1:1)*n(t,-o);if(t<0)return(o%2?-1:1)*n(-t,o);if(0===o)return f(t);if(1===o)return g(t);if(0===t)return 0;var u=0;if(t>o)u=e(t,o,f(t),g(t),-1);else{for(var i=!1,a=0,c=0,l=1,s=0,h=2/t,v=2*r.floor((o+r.floor(r.sqrt(40*o)))/2);v>0;v--)s=v*h*l-a,a=l,l=s,r.abs(l)>1e10&&(l*=1e-10,a*=1e-10,u*=1e-10,c*=1e-10),i&&(c+=l),i=!i,v==o&&(u=a);u/=c=2*c-l}return u}}(),M=(u=.636619772,i=[-2957821389,7062834065,-512359803.6,10879881.29,-86327.92757,228.4622733].reverse(),a=[40076544269,745249964.8,7189466.438,47447.2647,226.1030244,1].reverse(),f=[1,-.001098628627,2734510407e-14,-2073370639e-15,2.093887211e-7].reverse(),c=[-.01562499995,.0001430488765,-6911147651e-15,7.621095161e-7,-9.34945152e-8].reverse(),l=[-4900604943e3,127527439e4,-51534381390,734926455.1,-4237922.726,8511.937935].reverse(),s=[249958057e5,424441966400,3733650367,22459040.02,102042.605,354.9632885,1].reverse(),h=[1,.00183105,-3516396496e-14,2457520174e-15,-2.40337019e-7].reverse(),g=[.04687499995,-.0002002690873,8449199096e-15,-8.8228987e-7,1.05787412e-7].reverse(),o((function(n){var e=0,o=0,l=0,s=n*n,h=n-.785398164;return n<8?e=(o=t(i,s))/(l=t(a,s))+u*E(n,0)*r.log(n):(o=t(f,s=64/s),l=t(c,s),e=r.sqrt(u/n)*(r.sin(h)*o+r.cos(h)*l*8/n)),e}),(function(n){var e=0,o=0,i=0,a=n*n,f=n-2.356194491;return n<8?e=(o=n*t(l,a))/(i=t(s,a))+u*(E(n,1)*r.log(n)-1/n):(o=t(h,a=64/a),i=t(g,a),e=r.sqrt(u/n)*(r.sin(f)*o+r.cos(f)*i*8/n)),e}),0,1,-1)),N=(v=[1,3.5156229,3.0899424,1.2067492,.2659732,.0360768,.0045813].reverse(),p=[.39894228,.01328592,.00225319,-.00157565,.00916281,-.02057706,.02635537,-.01647633,.00392377].reverse(),m=[.5,.87890594,.51498869,.15084934,.02658733,.00301532,32411e-8].reverse(),d=[.39894228,-.03988024,-.00362018,.00163801,-.01031555,.02282967,-.02895312,.01787654,-.00420059].reverse(),function n(e,o){if(0===(o=Math.round(o)))return function(n){return n<=3.75?t(v,n*n/14.0625):r.exp(r.abs(n))/r.sqrt(r.abs(n))*t(p,3.75/r.abs(n))}(e);if(1===o)return function(n){return n<3.75?n*t(m,n*n/14.0625):(n<0?-1:1)*r.exp(r.abs(n))/r.sqrt(r.abs(n))*t(d,3.75/r.abs(n))}(e);if(o<0)return NaN;if(0===r.abs(e))return 0;if(e==1/0)return 1/0;var u,i=0,a=2/r.abs(e),f=0,c=1,l=0;for(u=2*r.round((o+r.round(r.sqrt(40*o)))/2);u>0;u--)l=u*a*c+f,f=c,c=l,r.abs(c)>1e10&&(c*=1e-10,f*=1e-10,i*=1e-10),u==o&&(i=f);return i*=n(e,0)/c,e<0&&o%2?-i:i}),w=function(){var n=[-.57721566,.4227842,.23069756,.0348859,.00262698,1075e-7,74e-7].reverse(),e=[1.25331414,-.07832358,.02189568,-.01062446,.00587872,-.0025154,53208e-8].reverse(),u=[1,.15443144,-.67278579,-.18156897,-.01919402,-.00110404,-4686e-8].reverse(),i=[1.25331414,.23498619,-.0365562,.01504268,-.00780353,.00325614,-68245e-8].reverse();return o((function(o){return o<=2?-r.log(o/2)*N(o,0)+t(n,o*o/4):r.exp(-o)/r.sqrt(o)*t(e,2/o)}),(function(n){return n<=2?r.log(n/2)*N(n,1)+1/n*t(u,n*n/4):r.exp(-n)/r.sqrt(n)*t(i,2/n)}),0,2,1)}();n.besselj=E,n.bessely=M,n.besseli=N,n.besselk=w},"undefined"==typeof DO_NOT_EXPORT_BESSEL?r(n):r({})}(Y);var H={exports:{}};!function(n,r){n.exports=function(){var n=function(n,r){var t=Array.prototype.concat,e=Array.prototype.slice,o=Object.prototype.toString;function u(r,t){var e=r>t?r:t;return n.pow(10,17-~~(n.log(e>0?e:-e)*n.LOG10E))}var i=Array.isArray||function(n){return"[object Array]"===o.call(n)};function a(n){return"[object Function]"===o.call(n)}function f(n){return"number"==typeof n&&n-n==0}function c(n){return t.apply([],n)}function l(){return new l._init(arguments)}function s(){return 0}function h(){return 1}function g(n,r){return n===r?1:0}l.fn=l.prototype,l._init=function(n){if(i(n[0]))if(i(n[0][0])){a(n[1])&&(n[0]=l.map(n[0],n[1]));for(var r=0;r<n[0].length;r++)this[r]=n[0][r];this.length=n[0].length}else this[0]=a(n[1])?l.map(n[0],n[1]):n[0],this.length=1;else if(f(n[0]))this[0]=l.seq.apply(null,n),this.length=1;else{if(n[0]instanceof l)return l(n[0].toArray());this[0]=[],this.length=1}return this},l._init.prototype=l.prototype,l._init.constructor=l,l.utils={calcRdx:u,isArray:i,isFunction:a,isNumber:f,toVector:c},l._random_fn=n.random,l.setRandom=function(n){if("function"!=typeof n)throw new TypeError("fn is not a function");l._random_fn=n},l.extend=function(n){var r,t;if(1===arguments.length){for(t in n)l[t]=n[t];return this}for(r=1;r<arguments.length;r++)for(t in arguments[r])n[t]=arguments[r][t];return n},l.rows=function(n){return n.length||1},l.cols=function(n){return n[0].length||1},l.dimensions=function(n){return{rows:l.rows(n),cols:l.cols(n)}},l.row=function(n,r){return i(r)?r.map((function(r){return l.row(n,r)})):n[r]},l.rowa=function(n,r){return l.row(n,r)},l.col=function(n,r){if(i(r)){var t=l.arange(n.length).map((function(){return new Array(r.length)}));return r.forEach((function(r,e){l.arange(n.length).forEach((function(o){t[o][e]=n[o][r]}))})),t}for(var e=new Array(n.length),o=0;o<n.length;o++)e[o]=[n[o][r]];return e},l.cola=function(n,r){return l.col(n,r).map((function(n){return n[0]}))},l.diag=function(n){for(var r=l.rows(n),t=new Array(r),e=0;e<r;e++)t[e]=[n[e][e]];return t},l.antidiag=function(n){for(var r=l.rows(n)-1,t=new Array(r),e=0;r>=0;r--,e++)t[e]=[n[e][r]];return t},l.transpose=function(n){var r,t,e,o,u,a=[];for(i(n[0])||(n=[n]),t=n.length,e=n[0].length,u=0;u<e;u++){for(r=new Array(t),o=0;o<t;o++)r[o]=n[o][u];a.push(r)}return 1===a.length?a[0]:a},l.map=function(n,r,t){var e,o,u,a,f;for(i(n[0])||(n=[n]),o=n.length,u=n[0].length,a=t?n:new Array(o),e=0;e<o;e++)for(a[e]||(a[e]=new Array(u)),f=0;f<u;f++)a[e][f]=r(n[e][f],e,f);return 1===a.length?a[0]:a},l.cumreduce=function(n,r,t){var e,o,u,a,f;for(i(n[0])||(n=[n]),o=n.length,u=n[0].length,a=t?n:new Array(o),e=0;e<o;e++)for(a[e]||(a[e]=new Array(u)),u>0&&(a[e][0]=n[e][0]),f=1;f<u;f++)a[e][f]=r(a[e][f-1],n[e][f]);return 1===a.length?a[0]:a},l.alter=function(n,r){return l.map(n,r,!0)},l.create=function(n,r,t){var e,o,u=new Array(n);for(a(r)&&(t=r,r=n),e=0;e<n;e++)for(u[e]=new Array(r),o=0;o<r;o++)u[e][o]=t(e,o);return u},l.zeros=function(n,r){return f(r)||(r=n),l.create(n,r,s)},l.ones=function(n,r){return f(r)||(r=n),l.create(n,r,h)},l.rand=function(n,r){return f(r)||(r=n),l.create(n,r,l._random_fn)},l.identity=function(n,r){return f(r)||(r=n),l.create(n,r,g)},l.symmetric=function(n){var r,t,e=n.length;if(n.length!==n[0].length)return!1;for(r=0;r<e;r++)for(t=0;t<e;t++)if(n[t][r]!==n[r][t])return!1;return!0},l.clear=function(n){return l.alter(n,s)},l.seq=function(n,r,t,e){a(e)||(e=!1);var o,i=[],f=u(n,r),c=(r*f-n*f)/((t-1)*f),l=n;for(o=0;l<=r&&o<t;l=(n*f+c*f*++o)/f)i.push(e?e(l,o):l);return i},l.arange=function(n,t,e){var o,u=[];if(e=e||1,t===r&&(t=n,n=0),n===t||0===e)return[];if(n<t&&e<0)return[];if(n>t&&e>0)return[];if(e>0)for(o=n;o<t;o+=e)u.push(o);else for(o=n;o>t;o+=e)u.push(o);return u},l.slice=function(){function n(n,t,e,o){var u,i=[],a=n.length;if(t===r&&e===r&&o===r)return l.copy(n);if(o=o||1,(t=(t=t||0)>=0?t:a+t)===(e=(e=e||n.length)>=0?e:a+e)||0===o)return[];if(t<e&&o<0)return[];if(t>e&&o>0)return[];if(o>0)for(u=t;u<e;u+=o)i.push(n[u]);else for(u=t;u>e;u+=o)i.push(n[u]);return i}function t(r,t){var e,o;return f((t=t||{}).row)?f(t.col)?r[t.row][t.col]:n(l.rowa(r,t.row),(e=t.col||{}).start,e.end,e.step):f(t.col)?n(l.cola(r,t.col),(o=t.row||{}).start,o.end,o.step):(o=t.row||{},e=t.col||{},n(r,o.start,o.end,o.step).map((function(r){return n(r,e.start,e.end,e.step)})))}return t}(),l.sliceAssign=function(t,e,o){var u,i;if(f(e.row)){if(f(e.col))return t[e.row][e.col]=o;e.col=e.col||{},e.col.start=e.col.start||0,e.col.end=e.col.end||t[0].length,e.col.step=e.col.step||1,u=l.arange(e.col.start,n.min(t.length,e.col.end),e.col.step);var a=e.row;return u.forEach((function(n,r){t[a][n]=o[r]})),t}if(f(e.col)){e.row=e.row||{},e.row.start=e.row.start||0,e.row.end=e.row.end||t.length,e.row.step=e.row.step||1,i=l.arange(e.row.start,n.min(t[0].length,e.row.end),e.row.step);var c=e.col;return i.forEach((function(n,r){t[n][c]=o[r]})),t}return o[0].length===r&&(o=[o]),e.row.start=e.row.start||0,e.row.end=e.row.end||t.length,e.row.step=e.row.step||1,e.col.start=e.col.start||0,e.col.end=e.col.end||t[0].length,e.col.step=e.col.step||1,i=l.arange(e.row.start,n.min(t.length,e.row.end),e.row.step),u=l.arange(e.col.start,n.min(t[0].length,e.col.end),e.col.step),i.forEach((function(n,r){u.forEach((function(e,u){t[n][e]=o[r][u]}))})),t},l.diagonal=function(n){var r=l.zeros(n.length,n.length);return n.forEach((function(n,t){r[t][t]=n})),r},l.copy=function(n){return n.map((function(n){return f(n)?n:n.map((function(n){return n}))}))};var v=l.prototype;return v.length=0,v.push=Array.prototype.push,v.sort=Array.prototype.sort,v.splice=Array.prototype.splice,v.slice=Array.prototype.slice,v.toArray=function(){return this.length>1?e.call(this):e.call(this)[0]},v.map=function(n,r){return l(l.map(this,n,r))},v.cumreduce=function(n,r){return l(l.cumreduce(this,n,r))},v.alter=function(n){return l.alter(this,n),this},function(n){for(var r=0;r<n.length;r++)!function(n){v[n]=function(r){var t,e=this;return r?(setTimeout((function(){r.call(e,v[n].call(e))})),this):(t=l[n](this),i(t)?l(t):t)}}(n[r])}("transpose clear symmetric rows cols dimensions diag antidiag".split(" ")),function(n){for(var r=0;r<n.length;r++)!function(n){v[n]=function(r,t){var e=this;return t?(setTimeout((function(){t.call(e,v[n].call(e,r))})),this):l(l[n](this,r))}}(n[r])}("row col".split(" ")),function(n){for(var r=0;r<n.length;r++)!function(n){v[n]=function(){return l(l[n].apply(null,arguments))}}(n[r])}("create zeros ones rand identity".split(" ")),l}(Math);return function(n,r){var t=n.utils.isFunction;function e(n,r){return n-r}function o(n,t,e){return r.max(t,r.min(n,e))}n.sum=function(n){for(var r=0,t=n.length;--t>=0;)r+=n[t];return r},n.sumsqrd=function(n){for(var r=0,t=n.length;--t>=0;)r+=n[t]*n[t];return r},n.sumsqerr=function(r){for(var t,e=n.mean(r),o=0,u=r.length;--u>=0;)o+=(t=r[u]-e)*t;return o},n.sumrow=function(n){for(var r=0,t=n.length;--t>=0;)r+=n[t];return r},n.product=function(n){for(var r=1,t=n.length;--t>=0;)r*=n[t];return r},n.min=function(n){for(var r=n[0],t=0;++t<n.length;)n[t]<r&&(r=n[t]);return r},n.max=function(n){for(var r=n[0],t=0;++t<n.length;)n[t]>r&&(r=n[t]);return r},n.unique=function(n){for(var r={},t=[],e=0;e<n.length;e++)r[n[e]]||(r[n[e]]=!0,t.push(n[e]));return t},n.mean=function(r){return n.sum(r)/r.length},n.meansqerr=function(r){return n.sumsqerr(r)/r.length},n.geomean=function(t){return r.pow(n.product(t),1/t.length)},n.median=function(n){var r=n.length,t=n.slice().sort(e);return 1&r?t[r/2|0]:(t[r/2-1]+t[r/2])/2},n.cumsum=function(r){return n.cumreduce(r,(function(n,r){return n+r}))},n.cumprod=function(r){return n.cumreduce(r,(function(n,r){return n*r}))},n.diff=function(n){var r,t=[],e=n.length;for(r=1;r<e;r++)t.push(n[r]-n[r-1]);return t},n.rank=function(n){var r,t=[],o={};for(r=0;r<n.length;r++)o[f=n[r]]?o[f]++:(o[f]=1,t.push(f));var u=t.sort(e),i={},a=1;for(r=0;r<u.length;r++){var f,c=o[f=u[r]],l=(a+(a+c-1))/2;i[f]=l,a+=c}return n.map((function(n){return i[n]}))},n.mode=function(n){var r,t=n.length,o=n.slice().sort(e),u=1,i=0,a=0,f=[];for(r=0;r<t;r++)o[r]===o[r+1]?u++:(u>i?(f=[o[r]],i=u,a=0):u===i&&(f.push(o[r]),a++),u=1);return 0===a?f[0]:f},n.range=function(r){return n.max(r)-n.min(r)},n.variance=function(r,t){return n.sumsqerr(r)/(r.length-(t?1:0))},n.pooledvariance=function(r){return r.reduce((function(r,t){return r+n.sumsqerr(t)}),0)/(r.reduce((function(n,r){return n+r.length}),0)-r.length)},n.deviation=function(r){for(var t=n.mean(r),e=r.length,o=new Array(e),u=0;u<e;u++)o[u]=r[u]-t;return o},n.stdev=function(t,e){return r.sqrt(n.variance(t,e))},n.pooledstdev=function(t){return r.sqrt(n.pooledvariance(t))},n.meandev=function(t){for(var e=n.mean(t),o=[],u=t.length-1;u>=0;u--)o.push(r.abs(t[u]-e));return n.mean(o)},n.meddev=function(t){for(var e=n.median(t),o=[],u=t.length-1;u>=0;u--)o.push(r.abs(t[u]-e));return n.median(o)},n.coeffvar=function(r){return n.stdev(r)/n.mean(r)},n.quartiles=function(n){var t=n.length,o=n.slice().sort(e);return[o[r.round(t/4)-1],o[r.round(t/2)-1],o[r.round(3*t/4)-1]]},n.quantiles=function(n,t,u,i){var a,f,c,l,s,h=n.slice().sort(e),g=[t.length],v=n.length;for(void 0===u&&(u=3/8),void 0===i&&(i=3/8),a=0;a<t.length;a++)c=v*(f=t[a])+(u+f*(1-u-i)),l=r.floor(o(c,1,v-1)),s=o(c-l,0,1),g[a]=(1-s)*h[l-1]+s*h[l];return g},n.percentile=function(n,r,t){var o=n.slice().sort(e),u=r*(o.length+(t?1:-1))+(t?0:1),i=parseInt(u),a=u-i;return i+1<o.length?o[i-1]+a*(o[i]-o[i-1]):o[i-1]},n.percentileOfScore=function(n,r,t){var e,o,u=0,i=n.length,a=!1;for("strict"===t&&(a=!0),o=0;o<i;o++)e=n[o],(a&&e<r||!a&&e<=r)&&u++;return u/i},n.histogram=function(t,e){e=e||4;var o,u=n.min(t),i=(n.max(t)-u)/e,a=t.length,f=[];for(o=0;o<e;o++)f[o]=0;for(o=0;o<a;o++)f[r.min(r.floor((t[o]-u)/i),e-1)]+=1;return f},n.covariance=function(r,t){var e,o=n.mean(r),u=n.mean(t),i=r.length,a=new Array(i);for(e=0;e<i;e++)a[e]=(r[e]-o)*(t[e]-u);return n.sum(a)/(i-1)},n.corrcoeff=function(r,t){return n.covariance(r,t)/n.stdev(r,1)/n.stdev(t,1)},n.spearmancoeff=function(r,t){return r=n.rank(r),t=n.rank(t),n.corrcoeff(r,t)},n.stanMoment=function(t,e){for(var o=n.mean(t),u=n.stdev(t),i=t.length,a=0,f=0;f<i;f++)a+=r.pow((t[f]-o)/u,e);return a/t.length},n.skewness=function(r){return n.stanMoment(r,3)},n.kurtosis=function(r){return n.stanMoment(r,4)-3};var u=n.prototype;!function(r){for(var e=0;e<r.length;e++)!function(r){u[r]=function(e,o){var i=[],a=0,f=this;if(t(e)&&(o=e,e=!1),o)return setTimeout((function(){o.call(f,u[r].call(f,e))})),this;if(this.length>1){for(f=!0===e?this:this.transpose();a<f.length;a++)i[a]=n[r](f[a]);return i}return n[r](this[0],e)}}(r[e])}("cumsum cumprod".split(" ")),function(r){for(var e=0;e<r.length;e++)!function(r){u[r]=function(e,o){var i=[],a=0,f=this;if(t(e)&&(o=e,e=!1),o)return setTimeout((function(){o.call(f,u[r].call(f,e))})),this;if(this.length>1){for("sumrow"!==r&&(f=!0===e?this:this.transpose());a<f.length;a++)i[a]=n[r](f[a]);return!0===e?n[r](n.utils.toVector(i)):i}return n[r](this[0],e)}}(r[e])}("sum sumsqrd sumsqerr sumrow product min max unique mean meansqerr geomean median diff rank mode range variance deviation stdev meandev meddev coeffvar quartiles histogram skewness kurtosis".split(" ")),function(r){for(var e=0;e<r.length;e++)!function(r){u[r]=function(){var e,o=[],i=0,a=this,f=Array.prototype.slice.call(arguments);if(t(f[f.length-1])){e=f[f.length-1];var c=f.slice(0,f.length-1);return setTimeout((function(){e.call(a,u[r].apply(a,c))})),this}e=void 0;var l=function(t){return n[r].apply(a,[t].concat(f))};if(this.length>1){for(a=a.transpose();i<a.length;i++)o[i]=l(a[i]);return o}return l(this[0])}}(r[e])}("quantiles percentileOfScore".split(" "))}(n,Math),function(n,r){n.gammaln=function(n){var t,e,o,u=0,i=[76.18009172947146,-86.50532032941678,24.01409824083091,-1.231739572450155,.001208650973866179,-5395239384953e-18],a=1.000000000190015;for(o=(e=t=n)+5.5,o-=(t+.5)*r.log(o);u<6;u++)a+=i[u]/++e;return r.log(2.5066282746310007*a/t)-o},n.loggam=function(n){var t,e,o,u,i,a,f,c=[.08333333333333333,-.002777777777777778,.0007936507936507937,-.0005952380952380952,.0008417508417508418,-.001917526917526918,.00641025641025641,-.02955065359477124,.1796443723688307,-1.3924322169059];if(t=n,f=0,1==n||2==n)return 0;for(n<=7&&(t=n+(f=r.floor(7-n))),e=1/(t*t),o=2*r.PI,i=c[9],a=8;a>=0;a--)i*=e,i+=c[a];if(u=i/t+.5*r.log(o)+(t-.5)*r.log(t)-t,n<=7)for(a=1;a<=f;a++)u-=r.log(t-1),t-=1;return u},n.gammafn=function(n){var t,e,o,u,i=[-1.716185138865495,24.76565080557592,-379.80425647094563,629.3311553128184,866.9662027904133,-31451.272968848367,-36144.413418691176,66456.14382024054],a=[-30.8402300119739,315.35062697960416,-1015.1563674902192,-3107.771671572311,22538.11842098015,4755.846277527881,-134659.9598649693,-115132.2596755535],f=!1,c=0,l=0,s=0,h=n;if(n>171.6243769536076)return 1/0;if(h<=0){if(!(u=h%1+36e-17))return 1/0;f=(1&h?-1:1)*r.PI/r.sin(r.PI*u),h=1-h}for(o=h,e=h<1?h++:(h-=c=(0|h)-1)-1,t=0;t<8;++t)s=(s+i[t])*e,l=l*e+a[t];if(u=s/l+1,o<h)u/=o;else if(o>h)for(t=0;t<c;++t)u*=h,h++;return f&&(u=f/u),u},n.gammap=function(r,t){return n.lowRegGamma(r,t)*n.gammafn(r)},n.lowRegGamma=function(t,e){var o,u=n.gammaln(t),i=t,a=1/t,f=a,c=e+1-t,l=1/1e-30,s=1/c,h=s,g=1,v=-~(8.5*r.log(t>=1?t:1/t)+.4*t+17);if(e<0||t<=0)return NaN;if(e<t+1){for(;g<=v;g++)a+=f*=e/++i;return a*r.exp(-e+t*r.log(e)-u)}for(;g<=v;g++)h*=(s=1/(s=(o=-g*(g-t))*s+(c+=2)))*(l=c+o/l);return 1-h*r.exp(-e+t*r.log(e)-u)},n.factorialln=function(r){return r<0?NaN:n.gammaln(r+1)},n.factorial=function(r){return r<0?NaN:n.gammafn(r+1)},n.combination=function(t,e){return t>170||e>170?r.exp(n.combinationln(t,e)):n.factorial(t)/n.factorial(e)/n.factorial(t-e)},n.combinationln=function(r,t){return n.factorialln(r)-n.factorialln(t)-n.factorialln(r-t)},n.permutation=function(r,t){return n.factorial(r)/n.factorial(r-t)},n.betafn=function(t,e){if(!(t<=0||e<=0))return t+e>170?r.exp(n.betaln(t,e)):n.gammafn(t)*n.gammafn(e)/n.gammafn(t+e)},n.betaln=function(r,t){return n.gammaln(r)+n.gammaln(t)-n.gammaln(r+t)},n.betacf=function(n,t,e){var o,u,i,a,f=1e-30,c=1,l=t+e,s=t+1,h=t-1,g=1,v=1-l*n/s;for(r.abs(v)<f&&(v=f),a=v=1/v;c<=100&&(v=1+(u=c*(e-c)*n/((h+(o=2*c))*(t+o)))*v,r.abs(v)<f&&(v=f),g=1+u/g,r.abs(g)<f&&(g=f),a*=(v=1/v)*g,v=1+(u=-(t+c)*(l+c)*n/((t+o)*(s+o)))*v,r.abs(v)<f&&(v=f),g=1+u/g,r.abs(g)<f&&(g=f),a*=i=(v=1/v)*g,!(r.abs(i-1)<3e-7));c++);return a},n.gammapinv=function(t,e){var o,u,i,a,f,c,l=0,s=e-1,h=1e-8,g=n.gammaln(e);if(t>=1)return r.max(100,e+100*r.sqrt(e));if(t<=0)return 0;for(e>1?(f=r.log(s),c=r.exp(s*(f-1)-g),a=t<.5?t:1-t,o=(2.30753+.27061*(u=r.sqrt(-2*r.log(a))))/(1+u*(.99229+.04481*u))-u,t<.5&&(o=-o),o=r.max(.001,e*r.pow(1-1/(9*e)-o/(3*r.sqrt(e)),3))):o=t<(u=1-e*(.253+.12*e))?r.pow(t/u,1/e):1-r.log(1-(t-u)/(1-u));l<12;l++){if(o<=0)return 0;if((o-=u=(i=(n.lowRegGamma(e,o)-t)/(u=e>1?c*r.exp(-(o-s)+s*(r.log(o)-f)):r.exp(-o+s*r.log(o)-g)))/(1-.5*r.min(1,i*((e-1)/o-1))))<=0&&(o=.5*(o+u)),r.abs(u)<h*o)break}return o},n.erf=function(n){var t,e,o,u,i=[-1.3026537197817094,.6419697923564902,.019476473204185836,-.00956151478680863,-.000946595344482036,.000366839497852761,42523324806907e-18,-20278578112534e-18,-1624290004647e-18,130365583558e-17,1.5626441722e-8,-8.5238095915e-8,6.529054439e-9,5.059343495e-9,-9.91364156e-10,-2.27365122e-10,96467911e-18,2394038e-18,-6886027e-18,894487e-18,313092e-18,-112708e-18,381e-18,7106e-18,-1523e-18,-94e-18,121e-18,-28e-18],a=i.length-1,f=!1,c=0,l=0;for(n<0&&(n=-n,f=!0),e=4*(t=2/(2+n))-2;a>0;a--)o=c,c=e*c-l+i[a],l=o;return u=t*r.exp(-n*n+.5*(i[0]+e*c)-l),f?u-1:1-u},n.erfc=function(r){return 1-n.erf(r)},n.erfcinv=function(t){var e,o,u,i,a=0;if(t>=2)return-100;if(t<=0)return 100;for(i=t<1?t:2-t,e=-.70711*((2.30753+.27061*(u=r.sqrt(-2*r.log(i/2))))/(1+u*(.99229+.04481*u))-u);a<2;a++)e+=(o=n.erfc(e)-i)/(1.1283791670955126*r.exp(-e*e)-e*o);return t<1?e:-e},n.ibetainv=function(t,e,o){var u,i,a,f,c,l,s,h,g,v,p=1e-8,m=e-1,d=o-1,E=0;if(t<=0)return 0;if(t>=1)return 1;for(e>=1&&o>=1?(a=t<.5?t:1-t,l=(2.30753+.27061*(f=r.sqrt(-2*r.log(a))))/(1+f*(.99229+.04481*f))-f,t<.5&&(l=-l),s=(l*l-3)/6,h=2/(1/(2*e-1)+1/(2*o-1)),g=l*r.sqrt(s+h)/h-(1/(2*o-1)-1/(2*e-1))*(s+5/6-2/(3*h)),l=e/(e+o*r.exp(2*g))):(u=r.log(e/(e+o)),i=r.log(o/(e+o)),l=t<(f=r.exp(e*u)/e)/(g=f+(c=r.exp(o*i)/o))?r.pow(e*g*t,1/e):1-r.pow(o*g*(1-t),1/o)),v=-n.gammaln(e)-n.gammaln(o)+n.gammaln(e+o);E<10;E++){if(0===l||1===l)return l;if((l-=f=(c=(n.ibeta(l,e,o)-t)/(f=r.exp(m*r.log(l)+d*r.log(1-l)+v)))/(1-.5*r.min(1,c*(m/l-d/(1-l)))))<=0&&(l=.5*(l+f)),l>=1&&(l=.5*(l+f+1)),r.abs(f)<p*l&&E>0)break}return l},n.ibeta=function(t,e,o){var u=0===t||1===t?0:r.exp(n.gammaln(e+o)-n.gammaln(e)-n.gammaln(o)+e*r.log(t)+o*r.log(1-t));return!(t<0||t>1)&&(t<(e+1)/(e+o+2)?u*n.betacf(t,e,o)/e:1-u*n.betacf(1-t,o,e)/o)},n.randn=function(t,e){var o,u,i,a,f;if(e||(e=t),t)return n.create(t,e,(function(){return n.randn()}));do{o=n._random_fn(),u=1.7156*(n._random_fn()-.5),f=(i=o-.449871)*i+(a=r.abs(u)+.386595)*(.196*a-.25472*i)}while(f>.27597&&(f>.27846||u*u>-4*r.log(o)*o*o));return u/o},n.randg=function(t,e,o){var u,i,a,f,c,l,s=t;if(o||(o=e),t||(t=1),e)return(l=n.zeros(e,o)).alter((function(){return n.randg(t)})),l;t<1&&(t+=1),u=t-1/3,i=1/r.sqrt(9*u);do{do{f=1+i*(c=n.randn())}while(f<=0);f*=f*f,a=n._random_fn()}while(a>1-.331*r.pow(c,4)&&r.log(a)>.5*c*c+u*(1-f+r.log(f)));if(t==s)return u*f;do{a=n._random_fn()}while(0===a);return r.pow(a,1/s)*u*f},function(r){for(var t=0;t<r.length;t++)!function(r){n.fn[r]=function(){return n(n.map(this,(function(t){return n[r](t)})))}}(r[t])}("gammaln gammafn factorial factorialln".split(" ")),function(r){for(var t=0;t<r.length;t++)!function(r){n.fn[r]=function(){return n(n[r].apply(null,arguments))}}(r[t])}("randn".split(" "))}(n,Math),function(n,r){function t(n,t,e,o){for(var u,i=0,a=1,f=1,c=1,l=0,s=0;r.abs((f-s)/f)>o;)s=f,a=c+(u=-(t+l)*(t+e+l)*n/(t+2*l)/(t+2*l+1))*a,f=(i=f+u*i)+(u=(l+=1)*(e-l)*n/(t+2*l-1)/(t+2*l))*f,i/=c=a+u*c,a/=c,f/=c,c=1;return f/t}function e(n){return n/r.abs(n)}function o(t,e,o){var u=12,i=6,a=-30,f=-50,c=60,l=8,s=3,h=2,g=3,v=[.9815606342467192,.9041172563704749,.7699026741943047,.5873179542866175,.3678314989981802,.1252334085114689],p=[.04717533638651183,.10693932599531843,.16007832854334622,.20316742672306592,.2334925365383548,.24914704581340277],m=.5*t;if(m>=l)return 1;var d,E=2*n.normal.cdf(m,0,1,1,0)-1;E=E>=r.exp(f/o)?r.pow(E,o):0;for(var M=m,N=(l-m)/(d=t>s?h:g),w=M+N,I=0,y=o-1,b=1;b<=d;b++){for(var T=0,S=.5*(w+M),A=.5*(w-M),D=1;D<=u;D++){var R,C=S+A*(i<D?v[(R=u-D+1)-1]:-v[(R=D)-1]),x=C*C;if(x>c)break;var O=2*n.normal.cdf(C,0,1,1,0)*.5-2*n.normal.cdf(C,t,1,1,0)*.5;O>=r.exp(a/y)&&(T+=O=p[R-1]*r.exp(-.5*x)*r.pow(O,y))}I+=T*=2*A*o/r.sqrt(2*r.PI),M=w,w+=N}return(E+=I)<=r.exp(a/e)?0:(E=r.pow(E,e))>=1?1:E}function u(n,t,e){var o=.322232421088,u=.099348462606,i=-1,a=.588581570495,f=-.342242088547,c=.531103462366,l=-.204231210125,s=.10353775285,h=-453642210148e-16,g=.0038560700634,v=.8832,p=.2368,m=1.214,d=1.208,E=1.4142,M=120,N=.5-.5*n,w=r.sqrt(r.log(1/(N*N))),I=w+((((w*h+l)*w+f)*w+i)*w+o)/((((w*g+s)*w+c)*w+a)*w+u);e<M&&(I+=(I*I*I+I)/e/4);var y=v-p*I;return e<M&&(y+=-m/e+d*I/e),I*(y*r.log(t-1)+E)}!function(r){for(var t=0;t<r.length;t++)!function(r){n[r]=function n(r,t,e){return this instanceof n?(this._a=r,this._b=t,this._c=e,this):new n(r,t,e)},n.fn[r]=function(t,e,o){var u=n[r](t,e,o);return u.data=this,u},n[r].prototype.sample=function(t){var e=this._a,o=this._b,u=this._c;return t?n.alter(t,(function(){return n[r].sample(e,o,u)})):n[r].sample(e,o,u)},function(t){for(var e=0;e<t.length;e++)!function(t){n[r].prototype[t]=function(e){var o=this._a,u=this._b,i=this._c;return e||0===e||(e=this.data),"number"!=typeof e?n.fn.map.call(e,(function(e){return n[r][t](e,o,u,i)})):n[r][t](e,o,u,i)}}(t[e])}("pdf cdf inv".split(" ")),function(t){for(var e=0;e<t.length;e++)!function(t){n[r].prototype[t]=function(){return n[r][t](this._a,this._b,this._c)}}(t[e])}("mean median mode variance".split(" "))}(r[t])}("beta centralF cauchy chisquare exponential gamma invgamma kumaraswamy laplace lognormal noncentralt normal pareto studentt weibull uniform binomial negbin hypgeom poisson triangular tukey arcsine".split(" ")),n.extend(n.beta,{pdf:function(t,e,o){return t>1||t<0?0:1==e&&1==o?1:e<512&&o<512?r.pow(t,e-1)*r.pow(1-t,o-1)/n.betafn(e,o):r.exp((e-1)*r.log(t)+(o-1)*r.log(1-t)-n.betaln(e,o))},cdf:function(r,t,e){return r>1||r<0?1*(r>1):n.ibeta(r,t,e)},inv:function(r,t,e){return n.ibetainv(r,t,e)},mean:function(n,r){return n/(n+r)},median:function(r,t){return n.ibetainv(.5,r,t)},mode:function(n,r){return(n-1)/(n+r-2)},sample:function(r,t){var e=n.randg(r);return e/(e+n.randg(t))},variance:function(n,t){return n*t/(r.pow(n+t,2)*(n+t+1))}}),n.extend(n.centralF,{pdf:function(t,e,o){var u;return t<0?0:e<=2?0===t&&e<2?1/0:0===t&&2===e?1:1/n.betafn(e/2,o/2)*r.pow(e/o,e/2)*r.pow(t,e/2-1)*r.pow(1+e/o*t,-(e+o)/2):(u=e*t/(o+t*e),e*(o/(o+t*e))/2*n.binomial.pdf((e-2)/2,(e+o-2)/2,u))},cdf:function(r,t,e){return r<0?0:n.ibeta(t*r/(t*r+e),t/2,e/2)},inv:function(r,t,e){return e/(t*(1/n.ibetainv(r,t/2,e/2)-1))},mean:function(n,r){return r>2?r/(r-2):void 0},mode:function(n,r){return n>2?r*(n-2)/(n*(r+2)):void 0},sample:function(r,t){return 2*n.randg(r/2)/r/(2*n.randg(t/2)/t)},variance:function(n,r){if(!(r<=4))return 2*r*r*(n+r-2)/(n*(r-2)*(r-2)*(r-4))}}),n.extend(n.cauchy,{pdf:function(n,t,e){return e<0?0:e/(r.pow(n-t,2)+r.pow(e,2))/r.PI},cdf:function(n,t,e){return r.atan((n-t)/e)/r.PI+.5},inv:function(n,t,e){return t+e*r.tan(r.PI*(n-.5))},median:function(n){return n},mode:function(n){return n},sample:function(t,e){return n.randn()*r.sqrt(1/(2*n.randg(.5)))*e+t}}),n.extend(n.chisquare,{pdf:function(t,e){return t<0?0:0===t&&2===e?.5:r.exp((e/2-1)*r.log(t)-t/2-e/2*r.log(2)-n.gammaln(e/2))},cdf:function(r,t){return r<0?0:n.lowRegGamma(t/2,r/2)},inv:function(r,t){return 2*n.gammapinv(r,.5*t)},mean:function(n){return n},median:function(n){return n*r.pow(1-2/(9*n),3)},mode:function(n){return n-2>0?n-2:0},sample:function(r){return 2*n.randg(r/2)},variance:function(n){return 2*n}}),n.extend(n.exponential,{pdf:function(n,t){return n<0?0:t*r.exp(-t*n)},cdf:function(n,t){return n<0?0:1-r.exp(-t*n)},inv:function(n,t){return-r.log(1-n)/t},mean:function(n){return 1/n},median:function(n){return 1/n*r.log(2)},mode:function(){return 0},sample:function(t){return-1/t*r.log(n._random_fn())},variance:function(n){return r.pow(n,-2)}}),n.extend(n.gamma,{pdf:function(t,e,o){return t<0?0:0===t&&1===e?1/o:r.exp((e-1)*r.log(t)-t/o-n.gammaln(e)-e*r.log(o))},cdf:function(r,t,e){return r<0?0:n.lowRegGamma(t,r/e)},inv:function(r,t,e){return n.gammapinv(r,t)*e},mean:function(n,r){return n*r},mode:function(n,r){if(n>1)return(n-1)*r},sample:function(r,t){return n.randg(r)*t},variance:function(n,r){return n*r*r}}),n.extend(n.invgamma,{pdf:function(t,e,o){return t<=0?0:r.exp(-(e+1)*r.log(t)-o/t-n.gammaln(e)+e*r.log(o))},cdf:function(r,t,e){return r<=0?0:1-n.lowRegGamma(t,e/r)},inv:function(r,t,e){return e/n.gammapinv(1-r,t)},mean:function(n,r){return n>1?r/(n-1):void 0},mode:function(n,r){return r/(n+1)},sample:function(r,t){return t/n.randg(r)},variance:function(n,r){if(!(n<=2))return r*r/((n-1)*(n-1)*(n-2))}}),n.extend(n.kumaraswamy,{pdf:function(n,t,e){return 0===n&&1===t?e:1===n&&1===e?t:r.exp(r.log(t)+r.log(e)+(t-1)*r.log(n)+(e-1)*r.log(1-r.pow(n,t)))},cdf:function(n,t,e){return n<0?0:n>1?1:1-r.pow(1-r.pow(n,t),e)},inv:function(n,t,e){return r.pow(1-r.pow(1-n,1/e),1/t)},mean:function(r,t){return t*n.gammafn(1+1/r)*n.gammafn(t)/n.gammafn(1+1/r+t)},median:function(n,t){return r.pow(1-r.pow(2,-1/t),1/n)},mode:function(n,t){if(n>=1&&t>=1&&1!==n&&1!==t)return r.pow((n-1)/(n*t-1),1/n)},variance:function(){throw new Error("variance not yet implemented")}}),n.extend(n.lognormal,{pdf:function(n,t,e){return n<=0?0:r.exp(-r.log(n)-.5*r.log(2*r.PI)-r.log(e)-r.pow(r.log(n)-t,2)/(2*e*e))},cdf:function(t,e,o){return t<0?0:.5+.5*n.erf((r.log(t)-e)/r.sqrt(2*o*o))},inv:function(t,e,o){return r.exp(-1.4142135623730951*o*n.erfcinv(2*t)+e)},mean:function(n,t){return r.exp(n+t*t/2)},median:function(n){return r.exp(n)},mode:function(n,t){return r.exp(n-t*t)},sample:function(t,e){return r.exp(n.randn()*e+t)},variance:function(n,t){return(r.exp(t*t)-1)*r.exp(2*n+t*t)}}),n.extend(n.noncentralt,{pdf:function(t,e,o){var u=1e-14;return r.abs(o)<u?n.studentt.pdf(t,e):r.abs(t)<u?r.exp(n.gammaln((e+1)/2)-o*o/2-.5*r.log(r.PI*e)-n.gammaln(e/2)):e/t*(n.noncentralt.cdf(t*r.sqrt(1+2/e),e+2,o)-n.noncentralt.cdf(t,e,o))},cdf:function(t,e,o){var u=1e-14,i=200;if(r.abs(o)<u)return n.studentt.cdf(t,e);var a=!1;t<0&&(a=!0,o=-o);for(var f=n.normal.cdf(-o,0,1),c=u+1,l=c,s=t*t/(t*t+e),h=0,g=r.exp(-o*o/2),v=r.exp(-o*o/2-.5*r.log(2)-n.gammaln(1.5))*o;h<i||l>u||c>u;)l=c,h>0&&(g*=o*o/(2*h),v*=o*o/(2*(h+.5))),f+=.5*(c=g*n.beta.cdf(s,h+.5,e/2)+v*n.beta.cdf(s,h+1,e/2)),h++;return a?1-f:f}}),n.extend(n.normal,{pdf:function(n,t,e){return r.exp(-.5*r.log(2*r.PI)-r.log(e)-r.pow(n-t,2)/(2*e*e))},cdf:function(t,e,o){return.5*(1+n.erf((t-e)/r.sqrt(2*o*o)))},inv:function(r,t,e){return-1.4142135623730951*e*n.erfcinv(2*r)+t},mean:function(n){return n},median:function(n){return n},mode:function(n){return n},sample:function(r,t){return n.randn()*t+r},variance:function(n,r){return r*r}}),n.extend(n.pareto,{pdf:function(n,t,e){return n<t?0:e*r.pow(t,e)/r.pow(n,e+1)},cdf:function(n,t,e){return n<t?0:1-r.pow(t/n,e)},inv:function(n,t,e){return t/r.pow(1-n,1/e)},mean:function(n,t){if(!(t<=1))return t*r.pow(n,t)/(t-1)},median:function(n,t){return n*(t*r.SQRT2)},mode:function(n){return n},variance:function(n,t){if(!(t<=2))return n*n*t/(r.pow(t-1,2)*(t-2))}}),n.extend(n.studentt,{pdf:function(t,e){return e=e>1e100?1e100:e,1/(r.sqrt(e)*n.betafn(.5,e/2))*r.pow(1+t*t/e,-(e+1)/2)},cdf:function(t,e){var o=e/2;return n.ibeta((t+r.sqrt(t*t+e))/(2*r.sqrt(t*t+e)),o,o)},inv:function(t,e){var o=n.ibetainv(2*r.min(t,1-t),.5*e,.5);return o=r.sqrt(e*(1-o)/o),t>.5?o:-o},mean:function(n){return n>1?0:void 0},median:function(){return 0},mode:function(){return 0},sample:function(t){return n.randn()*r.sqrt(t/(2*n.randg(t/2)))},variance:function(n){return n>2?n/(n-2):n>1?1/0:void 0}}),n.extend(n.weibull,{pdf:function(n,t,e){return n<0||t<0||e<0?0:e/t*r.pow(n/t,e-1)*r.exp(-r.pow(n/t,e))},cdf:function(n,t,e){return n<0?0:1-r.exp(-r.pow(n/t,e))},inv:function(n,t,e){return t*r.pow(-r.log(1-n),1/e)},mean:function(r,t){return r*n.gammafn(1+1/t)},median:function(n,t){return n*r.pow(r.log(2),1/t)},mode:function(n,t){return t<=1?0:n*r.pow((t-1)/t,1/t)},sample:function(t,e){return t*r.pow(-r.log(n._random_fn()),1/e)},variance:function(t,e){return t*t*n.gammafn(1+2/e)-r.pow(n.weibull.mean(t,e),2)}}),n.extend(n.uniform,{pdf:function(n,r,t){return n<r||n>t?0:1/(t-r)},cdf:function(n,r,t){return n<r?0:n<t?(n-r)/(t-r):1},inv:function(n,r,t){return r+n*(t-r)},mean:function(n,r){return.5*(n+r)},median:function(r,t){return n.mean(r,t)},mode:function(){throw new Error("mode is not yet implemented")},sample:function(r,t){return r/2+t/2+(t/2-r/2)*(2*n._random_fn()-1)},variance:function(n,t){return r.pow(t-n,2)/12}}),n.extend(n.binomial,{pdf:function(t,e,o){return 0===o||1===o?e*o===t?1:0:n.combination(e,t)*r.pow(o,t)*r.pow(1-o,e-t)},cdf:function(e,o,u){var i,a=1e-10;if(e<0)return 0;if(e>=o)return 1;if(u<0||u>1||o<=0)return NaN;var f=u,c=(e=r.floor(e))+1,l=o-e,s=c+l,h=r.exp(n.gammaln(s)-n.gammaln(l)-n.gammaln(c)+c*r.log(f)+l*r.log(1-f));return i=f<(c+1)/(s+2)?h*t(f,c,l,a):1-h*t(1-f,l,c,a),r.round(1/a*(1-i))/(1/a)}}),n.extend(n.negbin,{pdf:function(t,e,o){return t===t>>>0&&(t<0?0:n.combination(t+e-1,e-1)*r.pow(1-o,t)*r.pow(o,e))},cdf:function(r,t,e){var o=0,u=0;if(r<0)return 0;for(;u<=r;u++)o+=n.negbin.pdf(u,t,e);return o}}),n.extend(n.hypgeom,{pdf:function(t,e,o,u){if(t!=t|0)return!1;if(t<0||t<o-(e-u))return 0;if(t>u||t>o)return 0;if(2*o>e)return 2*u>e?n.hypgeom.pdf(e-o-u+t,e,e-o,e-u):n.hypgeom.pdf(u-t,e,e-o,u);if(2*u>e)return n.hypgeom.pdf(o-t,e,o,e-u);if(o<u)return n.hypgeom.pdf(t,e,u,o);for(var i=1,a=0,f=0;f<t;f++){for(;i>1&&a<u;)i*=1-o/(e-a),a++;i*=(u-f)*(o-f)/((f+1)*(e-o-u+f+1))}for(;a<u;a++)i*=1-o/(e-a);return r.min(1,r.max(0,i))},cdf:function(t,e,o,u){if(t<0||t<o-(e-u))return 0;if(t>=u||t>=o)return 1;if(2*o>e)return 2*u>e?n.hypgeom.cdf(e-o-u+t,e,e-o,e-u):1-n.hypgeom.cdf(u-t-1,e,e-o,u);if(2*u>e)return 1-n.hypgeom.cdf(o-t-1,e,o,e-u);if(o<u)return n.hypgeom.cdf(t,e,u,o);for(var i=1,a=1,f=0,c=0;c<t;c++){for(;i>1&&f<u;){var l=1-o/(e-f);a*=l,i*=l,f++}i+=a*=(u-c)*(o-c)/((c+1)*(e-o-u+c+1))}for(;f<u;f++)i*=1-o/(e-f);return r.min(1,r.max(0,i))}}),n.extend(n.poisson,{pdf:function(t,e){return e<0||t%1!=0||t<0?0:r.pow(e,t)*r.exp(-e)/n.factorial(t)},cdf:function(r,t){var e=[],o=0;if(r<0)return 0;for(;o<=r;o++)e.push(n.poisson.pdf(o,t));return n.sum(e)},mean:function(n){return n},variance:function(n){return n},sampleSmall:function(t){var e=1,o=0,u=r.exp(-t);do{o++,e*=n._random_fn()}while(e>u);return o-1},sampleLarge:function(t){var e,o,u,i,a,f,c,l,s,h,g=t;for(i=r.sqrt(g),a=r.log(g),f=.02483*(c=.931+2.53*i)-.059,l=1.1239+1.1328/(c-3.4),s=.9277-3.6224/(c-2);;){if(o=r.random()-.5,u=r.random(),h=.5-r.abs(o),e=r.floor((2*f/h+c)*o+g+.43),h>=.07&&u<=s)return e;if(!(e<0||h<.013&&u>h)&&r.log(u)+r.log(l)-r.log(f/(h*h)+c)<=e*a-g-n.loggam(e+1))return e}},sample:function(n){return n<10?this.sampleSmall(n):this.sampleLarge(n)}}),n.extend(n.triangular,{pdf:function(n,r,t,e){return t<=r||e<r||e>t?NaN:n<r||n>t?0:n<e?2*(n-r)/((t-r)*(e-r)):n===e?2/(t-r):2*(t-n)/((t-r)*(t-e))},cdf:function(n,t,e,o){return e<=t||o<t||o>e?NaN:n<=t?0:n>=e?1:n<=o?r.pow(n-t,2)/((e-t)*(o-t)):1-r.pow(e-n,2)/((e-t)*(e-o))},inv:function(n,t,e,o){return e<=t||o<t||o>e?NaN:n<=(o-t)/(e-t)?t+(e-t)*r.sqrt(n*((o-t)/(e-t))):t+(e-t)*(1-r.sqrt((1-n)*(1-(o-t)/(e-t))))},mean:function(n,r,t){return(n+r+t)/3},median:function(n,t,e){return e<=(n+t)/2?t-r.sqrt((t-n)*(t-e))/r.sqrt(2):e>(n+t)/2?n+r.sqrt((t-n)*(e-n))/r.sqrt(2):void 0},mode:function(n,r,t){return t},sample:function(t,e,o){var u=n._random_fn();return u<(o-t)/(e-t)?t+r.sqrt(u*(e-t)*(o-t)):e-r.sqrt((1-u)*(e-t)*(e-o))},variance:function(n,r,t){return(n*n+r*r+t*t-n*r-n*t-r*t)/18}}),n.extend(n.arcsine,{pdf:function(n,t,e){return e<=t?NaN:n<=t||n>=e?0:2/r.PI*r.pow(r.pow(e-t,2)-r.pow(2*n-t-e,2),-.5)},cdf:function(n,t,e){return n<t?0:n<e?2/r.PI*r.asin(r.sqrt((n-t)/(e-t))):1},inv:function(n,t,e){return t+(.5-.5*r.cos(r.PI*n))*(e-t)},mean:function(n,r){return r<=n?NaN:(n+r)/2},median:function(n,r){return r<=n?NaN:(n+r)/2},mode:function(){throw new Error("mode is not yet implemented")},sample:function(t,e){return(t+e)/2+(e-t)/2*r.sin(2*r.PI*n.uniform.sample(0,1))},variance:function(n,t){return t<=n?NaN:r.pow(t-n,2)/8}}),n.extend(n.laplace,{pdf:function(n,t,e){return e<=0?0:r.exp(-r.abs(n-t)/e)/(2*e)},cdf:function(n,t,e){return e<=0?0:n<t?.5*r.exp((n-t)/e):1-.5*r.exp(-(n-t)/e)},mean:function(n){return n},median:function(n){return n},mode:function(n){return n},variance:function(n,r){return 2*r*r},sample:function(t,o){var u=n._random_fn()-.5;return t-o*e(u)*r.log(1-2*r.abs(u))}}),n.extend(n.tukey,{cdf:function(t,e,u){var i=1,a=e,f=16,c=8,l=-30,s=1e-14,h=100,g=800,v=5e3,p=25e3,m=1,d=.5,E=.25,M=.125,N=[.9894009349916499,.9445750230732326,.8656312023878318,.755404408355003,.6178762444026438,.45801677765722737,.2816035507792589,.09501250983763744],w=[.027152459411754096,.062253523938647894,.09515851168249279,.12462897125553388,.14959598881657674,.16915651939500254,.18260341504492358,.1894506104550685];if(t<=0)return 0;if(u<2||i<1||a<2)return NaN;if(!Number.isFinite(t))return 1;if(u>p)return o(t,i,a);var I,y=.5*u,b=y*r.log(u)-u*r.log(2)-n.gammaln(y),T=y-1,S=.25*u;I=u<=h?m:u<=g?d:u<=v?E:M,b+=r.log(I);for(var A=0,D=1;D<=50;D++){for(var R=0,C=(2*D-1)*I,x=1;x<=f;x++){var O,P;c<x?(O=x-c-1,P=b+T*r.log(C+N[O]*I)-(N[O]*I+C)*S):(O=x-1,P=b+T*r.log(C-N[O]*I)+(N[O]*I-C)*S),P>=l&&(R+=o(c<x?t*r.sqrt(.5*(N[O]*I+C)):t*r.sqrt(.5*(-N[O]*I+C)),i,a)*w[O]*r.exp(P))}if(D*I>=1&&R<=s)break;A+=R}if(R>s)throw new Error("tukey.cdf failed to converge");return A>1&&(A=1),A},inv:function(t,e,o){var i=1e-4,a=50;if(o<2||e<2)return NaN;if(t<0||t>1)return NaN;if(0===t)return 0;if(1===t)return 1/0;var f,c=u(t,e,o),l=n.tukey.cdf(c,e,o)-t;f=l>0?r.max(0,c-1):c+1;for(var s,h=n.tukey.cdf(f,e,o)-t,g=1;g<a;g++)if(s=f-h*(f-c)/(h-l),l=h,c=f,s<0&&(s=0,h=-t),h=n.tukey.cdf(s,e,o)-t,f=s,r.abs(f-c)<i)return s;throw new Error("tukey.inv failed to converge")}})}(n,Math),function(n,r){var t=Array.prototype.push,e=n.utils.isArray;function o(r){return e(r)||r instanceof n}n.extend({add:function(r,t){return o(t)?(o(t[0])||(t=[t]),n.map(r,(function(n,r,e){return n+t[r][e]}))):n.map(r,(function(n){return n+t}))},subtract:function(r,t){return o(t)?(o(t[0])||(t=[t]),n.map(r,(function(n,r,e){return n-t[r][e]||0}))):n.map(r,(function(n){return n-t}))},divide:function(r,t){return o(t)?(o(t[0])||(t=[t]),n.multiply(r,n.inv(t))):n.map(r,(function(n){return n/t}))},multiply:function(r,t){var e,u,i,a,f,c,l,s;if(void 0===r.length&&void 0===t.length)return r*t;if(f=r.length,c=r[0].length,l=n.zeros(f,i=o(t)?t[0].length:c),s=0,o(t)){for(;s<i;s++)for(e=0;e<f;e++){for(a=0,u=0;u<c;u++)a+=r[e][u]*t[u][s];l[e][s]=a}return 1===f&&1===s?l[0][0]:l}return n.map(r,(function(n){return n*t}))},outer:function(r,t){return n.multiply(r.map((function(n){return[n]})),[t])},dot:function(r,t){o(r[0])||(r=[r]),o(t[0])||(t=[t]);for(var e,u,i=1===r[0].length&&1!==r.length?n.transpose(r):r,a=1===t[0].length&&1!==t.length?n.transpose(t):t,f=[],c=0,l=i.length,s=i[0].length;c<l;c++){for(f[c]=[],e=0,u=0;u<s;u++)e+=i[c][u]*a[c][u];f[c]=e}return 1===f.length?f[0]:f},pow:function(t,e){return n.map(t,(function(n){return r.pow(n,e)}))},exp:function(t){return n.map(t,(function(n){return r.exp(n)}))},log:function(t){return n.map(t,(function(n){return r.log(n)}))},abs:function(t){return n.map(t,(function(n){return r.abs(n)}))},norm:function(n,t){var e=0,u=0;for(isNaN(t)&&(t=2),o(n[0])&&(n=n[0]);u<n.length;u++)e+=r.pow(r.abs(n[u]),t);return r.pow(e,1/t)},angle:function(t,e){return r.acos(n.dot(t,e)/(n.norm(t)*n.norm(e)))},aug:function(n,r){var e,o=[];for(e=0;e<n.length;e++)o.push(n[e].slice());for(e=0;e<o.length;e++)t.apply(o[e],r[e]);return o},inv:function(r){for(var t,e=r.length,o=r[0].length,u=n.identity(e,o),i=n.gauss_jordan(r,u),a=[],f=0;f<e;f++)for(a[f]=[],t=o;t<i[0].length;t++)a[f][t-o]=i[f][t];return a},det:function(n){var r,t=n.length,e=2*t,o=new Array(e),u=t-1,i=e-1,a=u-t+1,f=i,c=0,l=0;if(2===t)return n[0][0]*n[1][1]-n[0][1]*n[1][0];for(;c<e;c++)o[c]=1;for(c=0;c<t;c++){for(r=0;r<t;r++)o[a<0?a+t:a]*=n[c][r],o[f<t?f+t:f]*=n[c][r],a++,f--;a=--u-t+1,f=--i}for(c=0;c<t;c++)l+=o[c];for(;c<e;c++)l-=o[c];return l},gauss_elimination:function(t,e){var o,u,i,a,f=0,c=0,l=t.length,s=t[0].length,h=1,g=0,v=[];for(o=(t=n.aug(t,e))[0].length,f=0;f<l;f++){for(u=t[f][f],c=f,a=f+1;a<s;a++)u<r.abs(t[a][f])&&(u=t[a][f],c=a);if(c!=f)for(a=0;a<o;a++)i=t[f][a],t[f][a]=t[c][a],t[c][a]=i;for(c=f+1;c<l;c++)for(h=t[c][f]/t[f][f],a=f;a<o;a++)t[c][a]=t[c][a]-h*t[f][a]}for(f=l-1;f>=0;f--){for(g=0,c=f+1;c<=l-1;c++)g+=v[c]*t[f][c];v[f]=(t[f][o-1]-g)/t[f][f]}return v},gauss_jordan:function(t,e){var o,u,i,a=n.aug(t,e),f=a.length,c=a[0].length,l=0;for(u=0;u<f;u++){var s=u;for(i=u+1;i<f;i++)r.abs(a[i][u])>r.abs(a[s][u])&&(s=i);var h=a[u];for(a[u]=a[s],a[s]=h,i=u+1;i<f;i++)for(l=a[i][u]/a[u][u],o=u;o<c;o++)a[i][o]-=a[u][o]*l}for(u=f-1;u>=0;u--){for(l=a[u][u],i=0;i<u;i++)for(o=c-1;o>u-1;o--)a[i][o]-=a[u][o]*a[i][u]/l;for(a[u][u]/=l,o=f;o<c;o++)a[u][o]/=l}return a},triaUpSolve:function(r,t){var e,o=r[0].length,u=n.zeros(1,o)[0],i=!1;return null!=t[0].length&&(t=t.map((function(n){return n[0]})),i=!0),n.arange(o-1,-1,-1).forEach((function(i){e=n.arange(i+1,o).map((function(n){return u[n]*r[i][n]})),u[i]=(t[i]-n.sum(e))/r[i][i]})),i?u.map((function(n){return[n]})):u},triaLowSolve:function(r,t){var e,o=r[0].length,u=n.zeros(1,o)[0],i=!1;return null!=t[0].length&&(t=t.map((function(n){return n[0]})),i=!0),n.arange(o).forEach((function(o){e=n.arange(o).map((function(n){return r[o][n]*u[n]})),u[o]=(t[o]-n.sum(e))/r[o][o]})),i?u.map((function(n){return[n]})):u},lu:function(r){var t,e=r.length,o=n.identity(e),u=n.zeros(r.length,r[0].length);return n.arange(e).forEach((function(n){u[0][n]=r[0][n]})),n.arange(1,e).forEach((function(i){n.arange(i).forEach((function(e){t=n.arange(e).map((function(n){return o[i][n]*u[n][e]})),o[i][e]=(r[i][e]-n.sum(t))/u[e][e]})),n.arange(i,e).forEach((function(e){t=n.arange(i).map((function(n){return o[i][n]*u[n][e]})),u[i][e]=r[t.length][e]-n.sum(t)}))})),[o,u]},cholesky:function(t){var e,o=t.length,u=n.zeros(t.length,t[0].length);return n.arange(o).forEach((function(i){e=n.arange(i).map((function(n){return r.pow(u[i][n],2)})),u[i][i]=r.sqrt(t[i][i]-n.sum(e)),n.arange(i+1,o).forEach((function(r){e=n.arange(i).map((function(n){return u[i][n]*u[r][n]})),u[r][i]=(t[i][r]-n.sum(e))/u[i][i]}))})),u},gauss_jacobi:function(t,e,o,u){for(var i,a,f,c,l=0,s=0,h=t.length,g=[],v=[],p=[];l<h;l++)for(g[l]=[],v[l]=[],p[l]=[],s=0;s<h;s++)l>s?(g[l][s]=t[l][s],v[l][s]=p[l][s]=0):l<s?(v[l][s]=t[l][s],g[l][s]=p[l][s]=0):(p[l][s]=t[l][s],g[l][s]=v[l][s]=0);for(f=n.multiply(n.multiply(n.inv(p),n.add(g,v)),-1),a=n.multiply(n.inv(p),e),i=o,c=n.add(n.multiply(f,o),a),l=2;r.abs(n.norm(n.subtract(c,i)))>u;)i=c,c=n.add(n.multiply(f,i),a),l++;return c},gauss_seidel:function(t,e,o,u){for(var i,a,f,c,l,s=0,h=t.length,g=[],v=[],p=[];s<h;s++)for(g[s]=[],v[s]=[],p[s]=[],i=0;i<h;i++)s>i?(g[s][i]=t[s][i],v[s][i]=p[s][i]=0):s<i?(v[s][i]=t[s][i],g[s][i]=p[s][i]=0):(p[s][i]=t[s][i],g[s][i]=v[s][i]=0);for(c=n.multiply(n.multiply(n.inv(n.add(p,g)),v),-1),f=n.multiply(n.inv(n.add(p,g)),e),a=o,l=n.add(n.multiply(c,o),f),s=2;r.abs(n.norm(n.subtract(l,a)))>u;)a=l,l=n.add(n.multiply(c,a),f),s+=1;return l},SOR:function(t,e,o,u,i){for(var a,f,c,l,s,h=0,g=t.length,v=[],p=[],m=[];h<g;h++)for(v[h]=[],p[h]=[],m[h]=[],a=0;a<g;a++)h>a?(v[h][a]=t[h][a],p[h][a]=m[h][a]=0):h<a?(p[h][a]=t[h][a],v[h][a]=m[h][a]=0):(m[h][a]=t[h][a],v[h][a]=p[h][a]=0);for(l=n.multiply(n.inv(n.add(m,n.multiply(v,i))),n.subtract(n.multiply(m,1-i),n.multiply(p,i))),c=n.multiply(n.multiply(n.inv(n.add(m,n.multiply(v,i))),e),i),f=o,s=n.add(n.multiply(l,o),c),h=2;r.abs(n.norm(n.subtract(s,f)))>u;)f=s,s=n.add(n.multiply(l,f),c),h++;return s},householder:function(t){for(var e,o,u,i,a=t.length,f=t[0].length,c=0,l=[],s=[];c<a-1;c++){for(e=0,i=c+1;i<f;i++)e+=t[i][c]*t[i][c];for(e=(t[c+1][c]>0?-1:1)*r.sqrt(e),o=r.sqrt((e*e-t[c+1][c]*e)/2),(l=n.zeros(a,1))[c+1][0]=(t[c+1][c]-e)/(2*o),u=c+2;u<a;u++)l[u][0]=t[u][c]/(2*o);s=n.subtract(n.identity(a,f),n.multiply(n.multiply(l,n.transpose(l)),2)),t=n.multiply(s,n.multiply(t,s))}return t},QR:function(){var t=n.sum,e=n.arange;function o(o){var u,i,a,f=o.length,c=o[0].length,l=n.zeros(c,c);for(o=n.copy(o),i=0;i<c;i++){for(l[i][i]=r.sqrt(t(e(f).map((function(n){return o[n][i]*o[n][i]})))),u=0;u<f;u++)o[u][i]=o[u][i]/l[i][i];for(a=i+1;a<c;a++)for(l[i][a]=t(e(f).map((function(n){return o[n][i]*o[n][a]}))),u=0;u<f;u++)o[u][a]=o[u][a]-o[u][i]*l[i][a]}return[o,l]}return o}(),lstsq:function(){function r(r){var t=(r=n.copy(r)).length,e=n.identity(t);return n.arange(t-1,-1,-1).forEach((function(t){n.sliceAssign(e,{row:t},n.divide(n.slice(e,{row:t}),r[t][t])),n.sliceAssign(r,{row:t},n.divide(n.slice(r,{row:t}),r[t][t])),n.arange(t).forEach((function(o){var u=n.multiply(r[o][t],-1),i=n.slice(r,{row:o}),a=n.multiply(n.slice(r,{row:t}),u);n.sliceAssign(r,{row:o},n.add(i,a));var f=n.slice(e,{row:o}),c=n.multiply(n.slice(e,{row:t}),u);n.sliceAssign(e,{row:o},n.add(f,c))}))})),e}function t(t,e){var o=!1;void 0===e[0].length&&(e=e.map((function(n){return[n]})),o=!0);var u=n.QR(t),i=u[0],a=u[1],f=t[0].length,c=n.slice(i,{col:{end:f}}),l=r(n.slice(a,{row:{end:f}})),s=n.transpose(c);void 0===s[0].length&&(s=[s]);var h=n.multiply(n.multiply(l,s),e);return void 0===h.length&&(h=[[h]]),o?h.map((function(n){return n[0]})):h}return t}(),jacobi:function(t){for(var e,o,u,i,a,f,c,l=1,s=t.length,h=n.identity(s,s),g=[];1===l;){for(a=t[0][1],u=0,i=1,e=0;e<s;e++)for(o=0;o<s;o++)e!=o&&a<r.abs(t[e][o])&&(a=r.abs(t[e][o]),u=e,i=o);for(f=t[u][u]===t[i][i]?t[u][i]>0?r.PI/4:-r.PI/4:r.atan(2*t[u][i]/(t[u][u]-t[i][i]))/2,(c=n.identity(s,s))[u][u]=r.cos(f),c[u][i]=-r.sin(f),c[i][u]=r.sin(f),c[i][i]=r.cos(f),h=n.multiply(h,c),t=n.multiply(n.multiply(n.inv(c),t),c),l=0,e=1;e<s;e++)for(o=1;o<s;o++)e!=o&&r.abs(t[e][o])>.001&&(l=1)}for(e=0;e<s;e++)g.push(t[e][e]);return[h,g]},rungekutta:function(n,r,t,e,o,u){var i,a,f;if(2===u)for(;e<=t;)o+=((i=r*n(e,o))+(a=r*n(e+r,o+i)))/2,e+=r;if(4===u)for(;e<=t;)o+=((i=r*n(e,o))+2*(a=r*n(e+r/2,o+i/2))+2*(f=r*n(e+r/2,o+a/2))+r*n(e+r,o+f))/6,e+=r;return o},romberg:function(n,t,e,o){for(var u,i,a,f,c,l=0,s=(e-t)/2,h=[],g=[],v=[];l<o/2;){for(c=n(t),a=t,f=0;a<=e;a+=s,f++)h[f]=a;for(u=h.length,a=1;a<u-1;a++)c+=(a%2!=0?4:2)*n(h[a]);c=s/3*(c+n(e)),v[l]=c,s/=2,l++}for(i=v.length,u=1;1!==i;){for(a=0;a<i-1;a++)g[a]=(r.pow(4,u)*v[a+1]-v[a])/(r.pow(4,u)-1);i=g.length,v=g,g=[],u++}return v},richardson:function(n,t,e,o){function u(n,r){for(var t,e=0,o=n.length;e<o;e++)n[e]===r&&(t=e);return t}for(var i,a,f,c,l,s=r.abs(e-n[u(n,e)+1]),h=0,g=[],v=[];o>=s;)i=u(n,e+o),a=u(n,e),g[h]=(t[i]-2*t[a]+t[2*a-i])/(o*o),o/=2,h++;for(c=g.length,f=1;1!=c;){for(l=0;l<c-1;l++)v[l]=(r.pow(4,f)*g[l+1]-g[l])/(r.pow(4,f)-1);c=v.length,g=v,v=[],f++}return g},simpson:function(n,r,t,e){for(var o,u=(t-r)/e,i=n(r),a=[],f=r,c=0,l=1;f<=t;f+=u,c++)a[c]=f;for(o=a.length;l<o-1;l++)i+=(l%2!=0?4:2)*n(a[l]);return u/3*(i+n(t))},hermite:function(n,r,t,e){for(var o,u=n.length,i=0,a=0,f=[],c=[],l=[],s=[];a<u;a++){for(f[a]=1,o=0;o<u;o++)a!=o&&(f[a]*=(e-n[o])/(n[a]-n[o]));for(c[a]=0,o=0;o<u;o++)a!=o&&(c[a]+=1/(n[a]-n[o]));l[a]=(1-2*(e-n[a])*c[a])*(f[a]*f[a]),s[a]=(e-n[a])*(f[a]*f[a]),i+=l[a]*r[a]+s[a]*t[a]}return i},lagrange:function(n,r,t){for(var e,o,u=0,i=0,a=n.length;i<a;i++){for(o=r[i],e=0;e<a;e++)i!=e&&(o*=(t-n[e])/(n[i]-n[e]));u+=o}return u},cubic_spline:function(r,t,e){for(var o,u=r.length,i=0,a=[],f=[],c=[],l=[],s=[],h=[],g=[];i<u-1;i++)s[i]=r[i+1]-r[i];for(c[0]=0,i=1;i<u-1;i++)c[i]=3/s[i]*(t[i+1]-t[i])-3/s[i-1]*(t[i]-t[i-1]);for(i=1;i<u-1;i++)a[i]=[],f[i]=[],a[i][i-1]=s[i-1],a[i][i]=2*(s[i-1]+s[i]),a[i][i+1]=s[i],f[i][0]=c[i];for(l=n.multiply(n.inv(a),f),o=0;o<u-1;o++)h[o]=(t[o+1]-t[o])/s[o]-s[o]*(l[o+1][0]+2*l[o][0])/3,g[o]=(l[o+1][0]-l[o][0])/(3*s[o]);for(o=0;o<u&&!(r[o]>e);o++);return t[o-=1]+(e-r[o])*h[o]+n.sq(e-r[o])*l[o]+(e-r[o])*n.sq(e-r[o])*g[o]},gauss_quadrature:function(){throw new Error("gauss_quadrature not yet implemented")},PCA:function(r){var t,e,o=r.length,u=r[0].length,i=0,a=[],f=[],c=[],l=[],s=[],h=[],g=[],v=[],p=[],m=[];for(i=0;i<o;i++)a[i]=n.sum(r[i])/u;for(i=0;i<u;i++)for(g[i]=[],t=0;t<o;t++)g[i][t]=r[t][i]-a[t];for(g=n.transpose(g),i=0;i<o;i++)for(v[i]=[],t=0;t<o;t++)v[i][t]=n.dot([g[i]],[g[t]])/(u-1);for(p=(c=n.jacobi(v))[0],f=c[1],m=n.transpose(p),i=0;i<f.length;i++)for(t=i;t<f.length;t++)f[i]<f[t]&&(e=f[i],f[i]=f[t],f[t]=e,l=m[i],m[i]=m[t],m[t]=l);for(h=n.transpose(g),i=0;i<o;i++)for(s[i]=[],t=0;t<h.length;t++)s[i][t]=n.dot([m[i]],[h[t]]);return[r,f,m,s]}}),function(r){for(var t=0;t<r.length;t++)!function(r){n.fn[r]=function(t,e){var o=this;return e?(setTimeout((function(){e.call(o,n.fn[r].call(o,t))}),15),this):"number"==typeof n[r](this,t)?n[r](this,t):n(n[r](this,t))}}(r[t])}("add divide multiply subtract dot pow exp log abs norm angle".split(" "))}(n,Math),function(n,r){var t=[].slice,e=n.utils.isNumber,o=n.utils.isArray;function u(n,t,e,o){if(n>1||e>1||n<=0||e<=0)throw new Error("Proportions should be greater than 0 and less than 1");var u=(n*t+e*o)/(t+o);return(n-e)/r.sqrt(u*(1-u)*(1/t+1/o))}n.extend({zscore:function(){var r=t.call(arguments);return e(r[1])?(r[0]-r[1])/r[2]:(r[0]-n.mean(r[1]))/n.stdev(r[1],r[2])},ztest:function(){var e,u=t.call(arguments);return o(u[1])?(e=n.zscore(u[0],u[1],u[3]),1===u[2]?n.normal.cdf(-r.abs(e),0,1):2*n.normal.cdf(-r.abs(e),0,1)):u.length>2?(e=n.zscore(u[0],u[1],u[2]),1===u[3]?n.normal.cdf(-r.abs(e),0,1):2*n.normal.cdf(-r.abs(e),0,1)):(e=u[0],1===u[1]?n.normal.cdf(-r.abs(e),0,1):2*n.normal.cdf(-r.abs(e),0,1))}}),n.extend(n.fn,{zscore:function(n,r){return(n-this.mean())/this.stdev(r)},ztest:function(t,e,o){var u=r.abs(this.zscore(t,o));return 1===e?n.normal.cdf(-u,0,1):2*n.normal.cdf(-u,0,1)}}),n.extend({tscore:function(){var e=t.call(arguments);return 4===e.length?(e[0]-e[1])/(e[2]/r.sqrt(e[3])):(e[0]-n.mean(e[1]))/(n.stdev(e[1],!0)/r.sqrt(e[1].length))},ttest:function(){var o,u=t.call(arguments);return 5===u.length?(o=r.abs(n.tscore(u[0],u[1],u[2],u[3])),1===u[4]?n.studentt.cdf(-o,u[3]-1):2*n.studentt.cdf(-o,u[3]-1)):e(u[1])?(o=r.abs(u[0]),1==u[2]?n.studentt.cdf(-o,u[1]-1):2*n.studentt.cdf(-o,u[1]-1)):(o=r.abs(n.tscore(u[0],u[1])),1==u[2]?n.studentt.cdf(-o,u[1].length-1):2*n.studentt.cdf(-o,u[1].length-1))}}),n.extend(n.fn,{tscore:function(n){return(n-this.mean())/(this.stdev(!0)/r.sqrt(this.cols()))},ttest:function(t,e){return 1===e?1-n.studentt.cdf(r.abs(this.tscore(t)),this.cols()-1):2*n.studentt.cdf(-r.abs(this.tscore(t)),this.cols()-1)}}),n.extend({anovafscore:function(){var e,o,u,i,a,f,c,l,s=t.call(arguments);if(1===s.length){for(a=new Array(s[0].length),c=0;c<s[0].length;c++)a[c]=s[0][c];s=a}for(o=new Array,c=0;c<s.length;c++)o=o.concat(s[c]);for(u=n.mean(o),e=0,c=0;c<s.length;c++)e+=s[c].length*r.pow(n.mean(s[c])-u,2);for(e/=s.length-1,f=0,c=0;c<s.length;c++)for(i=n.mean(s[c]),l=0;l<s[c].length;l++)f+=r.pow(s[c][l]-i,2);return e/(f/=o.length-s.length)},anovaftest:function(){var r,o,u,i,a=t.call(arguments);if(e(a[0]))return 1-n.centralF.cdf(a[0],a[1],a[2]);var f=n.anovafscore(a);for(r=a.length-1,u=0,i=0;i<a.length;i++)u+=a[i].length;return o=u-r-1,1-n.centralF.cdf(f,r,o)},ftest:function(r,t,e){return 1-n.centralF.cdf(r,t,e)}}),n.extend(n.fn,{anovafscore:function(){return n.anovafscore(this.toArray())},anovaftes:function(){var r,t=0;for(r=0;r<this.length;r++)t+=this[r].length;return n.ftest(this.anovafscore(),this.length-1,t-this.length)}}),n.extend({qscore:function(){var o,u,i,a,f,c=t.call(arguments);return e(c[0])?(o=c[0],u=c[1],i=c[2],a=c[3],f=c[4]):(o=n.mean(c[0]),u=n.mean(c[1]),i=c[0].length,a=c[1].length,f=c[2]),r.abs(o-u)/(f*r.sqrt((1/i+1/a)/2))},qtest:function(){var r,e=t.call(arguments);3===e.length?(r=e[0],e=e.slice(1)):7===e.length?(r=n.qscore(e[0],e[1],e[2],e[3],e[4]),e=e.slice(5)):(r=n.qscore(e[0],e[1],e[2]),e=e.slice(3));var o=e[0],u=e[1];return 1-n.tukey.cdf(r,u,o-u)},tukeyhsd:function(r){for(var t=n.pooledstdev(r),e=r.map((function(r){return n.mean(r)})),o=r.reduce((function(n,r){return n+r.length}),0),u=[],i=0;i<r.length;++i)for(var a=i+1;a<r.length;++a){var f=n.qtest(e[i],e[a],r[i].length,r[a].length,t,o,r.length);u.push([[i,a],f])}return u}}),n.extend({normalci:function(){var e,o=t.call(arguments),u=new Array(2);return e=4===o.length?r.abs(n.normal.inv(o[1]/2,0,1)*o[2]/r.sqrt(o[3])):r.abs(n.normal.inv(o[1]/2,0,1)*n.stdev(o[2])/r.sqrt(o[2].length)),u[0]=o[0]-e,u[1]=o[0]+e,u},tci:function(){var e,o=t.call(arguments),u=new Array(2);return e=4===o.length?r.abs(n.studentt.inv(o[1]/2,o[3]-1)*o[2]/r.sqrt(o[3])):r.abs(n.studentt.inv(o[1]/2,o[2].length-1)*n.stdev(o[2],!0)/r.sqrt(o[2].length)),u[0]=o[0]-e,u[1]=o[0]+e,u},significant:function(n,r){return n<r}}),n.extend(n.fn,{normalci:function(r,t){return n.normalci(r,t,this.toArray())},tci:function(r,t){return n.tci(r,t,this.toArray())}}),n.extend(n.fn,{oneSidedDifferenceOfProportions:function(r,t,e,o){var i=u(r,t,e,o);return n.ztest(i,1)},twoSidedDifferenceOfProportions:function(r,t,e,o){var i=u(r,t,e,o);return n.ztest(i,2)}})}(n,Math),n.models=function(){function r(r){var e=r[0].length;return n.arange(e).map((function(o){var u=n.arange(e).filter((function(n){return n!==o}));return t(n.col(r,o).map((function(n){return n[0]})),n.col(r,u))}))}function t(r,t){var e=r.length,o=t[0].length-1,u=e-o-1,i=n.lstsq(t,r),a=n.multiply(t,i.map((function(n){return[n]}))).map((function(n){return n[0]})),f=n.subtract(r,a),c=n.mean(r),l=n.sum(a.map((function(n){return Math.pow(n-c,2)}))),s=n.sum(r.map((function(n,r){return Math.pow(n-a[r],2)}))),h=l+s;return{exog:t,endog:r,nobs:e,df_model:o,df_resid:u,coef:i,predict:a,resid:f,ybar:c,SST:h,SSE:l,SSR:s,R2:l/h}}function e(t){var e=r(t.exog),o=Math.sqrt(t.SSR/t.df_resid),u=e.map((function(n){var r=n.SST,t=n.R2;return o/Math.sqrt(r*(1-t))})),i=t.coef.map((function(n,r){return(n-0)/u[r]})),a=i.map((function(r){var e=n.studentt.cdf(r,t.df_resid);return 2*(e>.5?1-e:e)})),f=n.studentt.inv(.975,t.df_resid),c=t.coef.map((function(n,r){var t=f*u[r];return[n-t,n+t]}));return{se:u,t:i,p:a,sigmaHat:o,interval95:c}}function o(r){var t,e,o,u=r.R2/r.df_model/((1-r.R2)/r.df_resid);return{F_statistic:u,pvalue:1-(t=u,e=r.df_model,o=r.df_resid,n.beta.cdf(t/(o/e+t),e/2,o/2))}}function u(n,r){var u=t(n,r),i=e(u),a=o(u),f=1-(1-u.R2)*((u.nobs-1)/u.df_resid);return u.t=i,u.f=a,u.adjust_R2=f,u}return{ols:u}}(),n.extend({buildxmatrix:function(){for(var r=new Array(arguments.length),t=0;t<arguments.length;t++){var e=[1];r[t]=e.concat(arguments[t])}return n(r)},builddxmatrix:function(){for(var r=new Array(arguments[0].length),t=0;t<arguments[0].length;t++){var e=[1];r[t]=e.concat(arguments[0][t])}return n(r)},buildjxmatrix:function(r){for(var t=new Array(r.length),e=0;e<r.length;e++)t[e]=r[e];return n.builddxmatrix(t)},buildymatrix:function(r){return n(r).transpose()},buildjymatrix:function(n){return n.transpose()},matrixmult:function(r,t){var e,o,u,i,a;if(r.cols()==t.rows()){if(t.rows()>1){for(i=[],e=0;e<r.rows();e++)for(i[e]=[],o=0;o<t.cols();o++){for(a=0,u=0;u<r.cols();u++)a+=r.toArray()[e][u]*t.toArray()[u][o];i[e][o]=a}return n(i)}for(i=[],e=0;e<r.rows();e++)for(i[e]=[],o=0;o<t.cols();o++){for(a=0,u=0;u<r.cols();u++)a+=r.toArray()[e][u]*t.toArray()[o];i[e][o]=a}return n(i)}},regress:function(r,t){var e=n.xtranspxinv(r),o=r.transpose(),u=n.matrixmult(n(e),o);return n.matrixmult(u,t)},regresst:function(r,t,e){var o=n.regress(r,t),u={anova:{}},i=n.jMatYBar(r,o);u.yBar=i;var a=t.mean();u.anova.residuals=n.residuals(t,i),u.anova.ssr=n.ssr(i,a),u.anova.msr=u.anova.ssr/(r[0].length-1),u.anova.sse=n.sse(t,i),u.anova.mse=u.anova.sse/(t.length-(r[0].length-1)-1),u.anova.sst=n.sst(t,a),u.anova.mst=u.anova.sst/(t.length-1),u.anova.r2=1-u.anova.sse/u.anova.sst,u.anova.r2<0&&(u.anova.r2=0),u.anova.fratio=u.anova.msr/u.anova.mse,u.anova.pvalue=n.anovaftest(u.anova.fratio,r[0].length-1,t.length-(r[0].length-1)-1),u.anova.rmse=Math.sqrt(u.anova.mse),u.anova.r2adj=1-u.anova.mse/u.anova.mst,u.anova.r2adj<0&&(u.anova.r2adj=0),u.stats=new Array(r[0].length);for(var f,c,l,s=n.xtranspxinv(r),h=0;h<o.length;h++)f=Math.sqrt(u.anova.mse*Math.abs(s[h][h])),c=Math.abs(o[h]/f),l=n.ttest(c,t.length-r[0].length-1,e),u.stats[h]=[o[h],f,c,l];return u.regress=o,u},xtranspx:function(r){return n.matrixmult(r.transpose(),r)},xtranspxinv:function(r){var t=n.matrixmult(r.transpose(),r);return n.inv(t)},jMatYBar:function(r,t){var e=n.matrixmult(r,t);return new n(e)},residuals:function(r,t){return n.matrixsubtract(r,t)},ssr:function(n,r){for(var t=0,e=0;e<n.length;e++)t+=Math.pow(n[e]-r,2);return t},sse:function(n,r){for(var t=0,e=0;e<n.length;e++)t+=Math.pow(n[e]-r[e],2);return t},sst:function(n,r){for(var t=0,e=0;e<n.length;e++)t+=Math.pow(n[e]-r,2);return t},matrixsubtract:function(r,t){for(var e=new Array(r.length),o=0;o<r.length;o++){e[o]=new Array(r[o].length);for(var u=0;u<r[o].length;u++)e[o][u]=r[o][u]-t[o][u]}return n(e)}}),n.jStat=n,n}()}(H);var j=H.exports;function B(n){return 0===(n=d(n))?e:n instanceof Error?n:String.fromCharCode(n)}function z(n){if(b(n))return n;var r=(n=n||"").charCodeAt(0);return isNaN(r)&&(r=e),r}function K(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;for(var t=0;(t=n.indexOf(!0))>-1;)n[t]="TRUE";for(var e=0;(e=n.indexOf(!1))>-1;)n[e]="FALSE";return n.join("")}var W=K;function Q(n,r){var t=I(n,r);return t||(n=E(n),(r=d(r))instanceof Error?r:new Array(r+1).join(n))}var $=B,Z=z;function J(n){return/^[01]{1,10}$/.test(n)}function nn(n,r,t){if(b(n=d(n),r=d(r)))return n;if("i"!==(t=void 0===t?"i":t)&&"j"!==t)return e;if(0===n&&0===r)return 0;if(0===n)return 1===r?t:r.toString()+t;if(0===r)return n.toString();var o=r>0?"+":"";return n.toString()+o+(1===r?t:r.toString()+t)}function rn(n,r){return r=void 0===r?0:r,b(n=d(n),r=d(r))?e:j.erf(n)}function tn(n){return isNaN(n)?e:j.erfc(n)}function en(n){var r=ln(n),t=on(n);return b(r,t)?e:Math.sqrt(Math.pow(r,2)+Math.pow(t,2))}function on(n){if(void 0===n||!0===n||!1===n)return e;if(0===n||"0"===n)return 0;if(["i","j"].indexOf(n)>=0)return 1;var r=(n=(n+="").replace("+i","+1i").replace("-i","-1i").replace("+j","+1j").replace("-j","-1j")).indexOf("+"),t=n.indexOf("-");0===r&&(r=n.indexOf("+",1)),0===t&&(t=n.indexOf("-",1));var o=n.substring(n.length-1,n.length),u="i"===o||"j"===o;return r>=0||t>=0?u?r>=0?isNaN(n.substring(0,r))||isNaN(n.substring(r+1,n.length-1))?i:Number(n.substring(r+1,n.length-1)):isNaN(n.substring(0,t))||isNaN(n.substring(t+1,n.length-1))?i:-Number(n.substring(t+1,n.length-1)):i:u?isNaN(n.substring(0,n.length-1))?i:n.substring(0,n.length-1):isNaN(n)?i:0}function un(n){var r=ln(n),o=on(n);return b(r,o)?e:0===r&&0===o?t:0===r&&o>0?Math.PI/2:0===r&&o<0?-Math.PI/2:0===o&&r>0?0:0===o&&r<0?-Math.PI:r>0?Math.atan(o/r):r<0&&o>=0?Math.atan(o/r)+Math.PI:Math.atan(o/r)-Math.PI}function an(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.cos(r)*(Math.exp(t)+Math.exp(-t))/2,-Math.sin(r)*(Math.exp(t)-Math.exp(-t))/2,o)}function fn(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.cos(t)*(Math.exp(r)+Math.exp(-r))/2,Math.sin(t)*(Math.exp(r)-Math.exp(-r))/2,o)}function cn(n,r){var t=ln(n),o=on(n),u=ln(r),a=on(r);if(b(t,o,u,a))return e;var f=n.substring(n.length-1),c=r.substring(r.length-1),l="i";if(("j"===f||"j"===c)&&(l="j"),0===u&&0===a)return i;var s=u*u+a*a;return nn((t*u+o*a)/s,(o*u-t*a)/s,l)}function ln(n){if(void 0===n||!0===n||!1===n)return e;if(0===n||"0"===n)return 0;if(["i","+i","1i","+1i","-i","-1i","j","+j","1j","+1j","-j","-1j"].indexOf(n)>=0)return 0;var r=(n+="").indexOf("+"),t=n.indexOf("-");0===r&&(r=n.indexOf("+",1)),0===t&&(t=n.indexOf("-",1));var o=n.substring(n.length-1,n.length),u="i"===o||"j"===o;return r>=0||t>=0?u?r>=0?isNaN(n.substring(0,r))||isNaN(n.substring(r+1,n.length-1))?i:Number(n.substring(0,r)):isNaN(n.substring(0,t))||isNaN(n.substring(t+1,n.length-1))?i:Number(n.substring(0,t)):i:u?isNaN(n.substring(0,n.length-1))?i:0:isNaN(n)?i:n}function sn(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.sin(r)*(Math.exp(t)+Math.exp(-t))/2,Math.cos(r)*(Math.exp(t)-Math.exp(-t))/2,o)}function hn(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.cos(t)*(Math.exp(r)-Math.exp(-r))/2,Math.sin(t)*(Math.exp(r)+Math.exp(-r))/2,o)}rn.PRECISE=function(){throw new Error("ERF.PRECISE is not implemented")},tn.PRECISE=function(){throw new Error("ERFC.PRECISE is not implemented")};var gn=[">",">=","<","<=","=","<>"],vn="operator",pn="literal",mn=[vn,pn],dn=vn,En=pn;function Mn(n,r){if(-1===mn.indexOf(r))throw new Error("Unsupported token type: "+r);return{value:n,type:r}}function Nn(n){for(var r="",t=[],e=0;e<n.length;e++){var o=n[e];0===e&&gn.indexOf(o)>=0?t.push(Mn(o,dn)):r+=o}return r.length>0&&t.push(Mn(function(n){return"string"!=typeof n||/^\d+(\.\d+)?$/.test(n)&&(n=-1===n.indexOf(".")?parseInt(n,10):parseFloat(n)),n}(r),En)),t.length>0&&t[0].type!==dn&&t.unshift(Mn("=",dn)),t}function wn(n){return Nn(function(n){for(var r=n.length,t=[],e=0,o="",u="";e<r;){var i=n.charAt(e);switch(i){case">":case"<":case"=":u+=i,o.length>0&&(t.push(o),o="");break;default:u.length>0&&(t.push(u),u=""),o+=i}e++}return o.length>0&&t.push(o),u.length>0&&t.push(u),t}(n))}var In=function(n){for(var r,t=[],e=0;e<n.length;e++){var o=n[e];switch(o.type){case dn:r=o.value;break;case En:t.push(o.value)}}return function(n,r){var t=!1;switch(r){case">":t=n[0]>n[1];break;case">=":t=n[0]>=n[1];break;case"<":t=n[0]<n[1];break;case"<=":t=n[0]<=n[1];break;case"=":t=n[0]==n[1];break;case"<>":t=n[0]!=n[1]}return t}(t,r)};var yn={};function bn(n){return[e,o,t,i,u,r].indexOf(n)>=0||"number"==typeof n&&(isNaN(n)||!isFinite(n))}function Tn(n){return bn(n)||n===a}function Sn(n){return!0===n||!1===n}function An(n){return"number"==typeof n&&!isNaN(n)&&isFinite(n)}function Dn(n){return"string"==typeof n}function Rn(){for(var n=[],r=0;r<arguments.length;++r){for(var t=!1,e=arguments[r],o=0;o<n.length&&!(t=n[o]===e);++o);t||n.push(e)}return n}yn.TYPE=function(n){switch(n){case r:return 1;case t:return 2;case e:return 3;case o:return 4;case u:return 5;case i:return 6;case a:return 7;case c:return 8}return a};var Cn=h;function xn(){var n=h(arguments),r=n.filter(y);if(0===r.length)return t;var e=I.apply(void 0,r);if(e)return e;for(var o,u=v(r),a=u.length,f=0,c=0,l=0;l<a;l++)f+=u[l],c+=1;return o=f/c,isNaN(o)&&(o=i),o}function On(){var n=h(arguments),r=n.filter(y);if(0===r.length)return t;var e=I.apply(void 0,r);if(e)return e;for(var o,u=r,a=u.length,f=0,c=0,l=0;l<a;l++){var s=u[l];"number"==typeof s&&(f+=s),!0===s&&f++,null!==s&&c++}return o=f/c,isNaN(o)&&(o=i),o}var Pn={DIST:function(n,r,t,o,u,i){return arguments.length<4?e:(u=void 0===u?0:u,i=void 0===i?1:i,b(n=d(n),r=d(r),t=d(t),u=d(u),i=d(i))?e:(n=(n-u)/(i-u),o?j.beta.cdf(n,r,t):j.beta.pdf(n,r,t)))},INV:function(n,r,t,o,u){return o=void 0===o?0:o,u=void 0===u?1:u,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u))?e:j.beta.inv(n,r,t)*(u-o)+o}},Ln={DIST:function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t),o=d(o))?e:o?j.binomial.cdf(n,r,t):j.binomial.pdf(n,r,t)}};Ln.DIST.RANGE=function(n,r,t,o){if(o=void 0===o?t:o,b(n=d(n),r=d(r),t=d(t),o=d(o)))return e;for(var u=0,i=t;i<=o;i++)u+=Er(n,i)*Math.pow(r,i)*Math.pow(1-r,n-i);return u},Ln.INV=function(n,r,t){if(b(n=d(n),r=d(r),t=d(t)))return e;for(var o=0;o<=n;){if(j.binomial.cdf(o,n,r)>=t)return o;o++}};var qn={};qn.DIST=function(n,r,t){return b(n=d(n),r=d(r))?e:t?j.chisquare.cdf(n,r):j.chisquare.pdf(n,r)},qn.DIST.RT=function(n,r){return!n|!r?a:n<1||r>Math.pow(10,10)?i:"number"!=typeof n||"number"!=typeof r?e:1-j.chisquare.cdf(n,r)},qn.INV=function(n,r){return b(n=d(n),r=d(r))?e:j.chisquare.inv(n,r)},qn.INV.RT=function(n,r){return!n|!r?a:n<0||n>1||r<1||r>Math.pow(10,10)?i:"number"!=typeof n||"number"!=typeof r?e:j.chisquare.inv(1-n,r)},qn.TEST=function(n,r){if(2!==arguments.length)return a;if(!(n instanceof Array&&r instanceof Array))return e;if(n.length!==r.length)return e;if(n[0]&&r[0]&&n[0].length!==r[0].length)return e;var t,o,u,i=n.length;for(o=0;o<i;o++)n[o]instanceof Array||(t=n[o],n[o]=[],n[o].push(t)),r[o]instanceof Array||(t=r[o],r[o]=[],r[o].push(t));var f=n[0].length,c=1===f?i-1:(i-1)*(f-1),l=0,s=Math.PI;for(o=0;o<i;o++)for(u=0;u<f;u++)l+=Math.pow(n[o][u]-r[o][u],2)/r[o][u];function h(n,r){var t=Math.exp(-.5*n);r%2==1&&(t*=Math.sqrt(2*n/s));for(var e=r;e>=2;)t=t*n/e,e-=2;for(var o=t,u=r;o>1e-10*t;)t+=o=o*n/(u+=2);return 1-t}return Math.round(1e6*h(l,c))/1e6};var Un={};function Fn(){var n=h(arguments);return v(n).length}function _n(){var n=h(arguments);return n.length-Vn(n)}function Vn(){for(var n,r=h(arguments),t=0,e=0;e<r.length;e++)null!=(n=r[e])&&""!==n||t++;return t}Un.NORM=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:j.normalci(1,n,r,t)[1]-1},Un.T=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:j.tci(1,n,r,t)[1]-1};var Gn={};Gn.P=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=j.mean(n),o=j.mean(r),u=0,i=n.length,a=0;a<i;a++)u+=(n[a]-t)*(r[a]-o);return u/i},Gn.S=function(n,r){return b(n=M(h(n)),r=M(h(r)))?e:j.covariance(n,r)};var kn={DIST:function(n,r,t){return b(n=d(n),r=d(r))?e:t?j.exponential.cdf(n,r):j.exponential.pdf(n,r)}},Xn={};function Yn(n,r,t){if(b(n=d(n),r=M(h(r)),t=M(h(t))))return e;for(var o=j.mean(t),u=j.mean(r),i=t.length,a=0,f=0,c=0;c<i;c++)a+=(t[c]-o)*(r[c]-u),f+=Math.pow(t[c]-o,2);var l=a/f;return u-l*o+l*n}function Hn(n){return(n=d(n))instanceof Error?n:0===n||parseInt(n,10)===n&&n<0?i:j.gammafn(n)}function jn(n){return(n=d(n))instanceof Error?n:j.gammaln(n)}Xn.DIST=function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t))?e:o?j.centralF.cdf(n,r,t):j.centralF.pdf(n,r,t)},Xn.DIST.RT=function(n,r,t){return 3!==arguments.length?a:n<0||r<1||t<1?i:"number"!=typeof n||"number"!=typeof r||"number"!=typeof t?e:1-j.centralF.cdf(n,r,t)},Xn.INV=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:n<=0||n>1?i:j.centralF.inv(n,r,t)},Xn.INV.RT=function(n,r,t){return 3!==arguments.length?a:n<0||n>1||r<1||r>Math.pow(10,10)||t<1||t>Math.pow(10,10)?i:"number"!=typeof n||"number"!=typeof r||"number"!=typeof t?e:j.centralF.inv(1-n,r,t)},Xn.TEST=function(n,r){if(!n||!r)return a;if(!(n instanceof Array&&r instanceof Array))return a;if(n.length<2||r.length<2)return t;var e=function(n,r){for(var t=0,e=0;e<n.length;e++)t+=Math.pow(n[e]-r,2);return t},o=Sr(n)/n.length,u=Sr(r)/r.length;return e(n,o)/(n.length-1)/(e(r,u)/(r.length-1))},Hn.DIST=function(n,r,t,o){return 4!==arguments.length?a:n<0||r<=0||t<=0||"number"!=typeof n||"number"!=typeof r||"number"!=typeof t?e:o?j.gamma.cdf(n,r,t,!0):j.gamma.pdf(n,r,t,!1)},Hn.INV=function(n,r,t){return 3!==arguments.length?a:n<0||n>1||r<=0||t<=0?i:"number"!=typeof n||"number"!=typeof r||"number"!=typeof t?e:j.gamma.inv(n,r,t)},jn.PRECISE=function(n){return 1!==arguments.length?a:n<=0?i:"number"!=typeof n?e:j.gammaln(n)};var Bn={};function zn(n,r){return b(n=M(h(n)),r=d(r))?n:r<0||n.length<r?e:n.sort((function(n,r){return r-n}))[r-1]}function Kn(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=j.mean(n),o=j.mean(r),u=r.length,i=0,a=0,f=0;f<u;f++)i+=(r[f]-o)*(n[f]-t),a+=Math.pow(r[f]-o,2);var c=i/a;return[c,t-c*o]}Bn.DIST=function(n,r,t,o,u){if(b(n=d(n),r=d(r),t=d(t),o=d(o)))return e;function i(n,r,t,e){return Er(t,n)*Er(e-t,r-n)/Er(e,r)}return u?function(n,r,t,e){for(var o=0,u=0;u<=n;u++)o+=i(u,r,t,e);return o}(n,r,t,o):i(n,r,t,o)};var Wn={};function Qn(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;var t=v(n);return 0===t.length?0:Math.max.apply(Math,t)}function $n(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;var t=S(n),e=j.median(t);return isNaN(e)&&(e=i),e}function Zn(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;var t=v(n);return 0===t.length?0:Math.min.apply(Math,t)}Wn.DIST=function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t))?e:o?j.lognormal.cdf(n,r,t):j.lognormal.pdf(n,r,t)},Wn.INV=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:j.lognormal.inv(n,r,t)};var Jn={MULT:function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r,t=n.length,e={},o=[],u=0,i=0;i<t;i++)e[r=n[i]]=e[r]?e[r]+1:1,e[r]>u&&(u=e[r],o=[]),e[r]===u&&(o[o.length]=r);return o},SNGL:function(){var n=M(h(arguments));return n instanceof Error?n:Jn.MULT(n).sort((function(n,r){return n-r}))[0]}},nr={DIST:function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t))?e:o?j.negbin.cdf(n,r,t):j.negbin.pdf(n,r,t)}},rr={};function tr(n,r){if(b(r=M(h(r)),n=M(h(n))))return e;for(var t=j.mean(n),o=j.mean(r),u=n.length,i=0,a=0,f=0,c=0;c<u;c++)i+=(n[c]-t)*(r[c]-o),a+=Math.pow(n[c]-t,2),f+=Math.pow(r[c]-o,2);return i/Math.sqrt(a*f)}rr.DIST=function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t))?e:t<=0?i:o?j.normal.cdf(n,r,t):j.normal.pdf(n,r,t)},rr.INV=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:j.normal.inv(n,r,t)},rr.S={},rr.S.DIST=function(n,r){return(n=d(n))instanceof Error?e:r?j.normal.cdf(n,0,1):j.normal.pdf(n,0,1)},rr.S.INV=function(n){return(n=d(n))instanceof Error?e:j.normal.inv(n,0,1)};var er={EXC:function(n,r){if(b(n=M(h(n)),r=d(r)))return e;var t=(n=n.sort((function(n,r){return n-r}))).length;if(r<1/(t+1)||r>1-1/(t+1))return i;var o=r*(t+1)-1,u=Math.floor(o);return p(o===u?n[o]:n[u]+(o-u)*(n[u+1]-n[u]))},INC:function(n,r){if(b(n=M(h(n)),r=d(r)))return e;var t=r*((n=n.sort((function(n,r){return n-r}))).length-1),o=Math.floor(t);return p(t===o?n[t]:n[o]+(t-o)*(n[o+1]-n[o]))}},or={};or.EXC=function(n,r,t){if(t=void 0===t?3:t,b(n=M(h(n)),r=d(r),t=d(t)))return e;n=n.sort((function(n,r){return n-r}));for(var o=Rn.apply(null,n),u=n.length,i=o.length,a=Math.pow(10,t),f=0,c=!1,l=0;!c&&l<i;)r===o[l]?(f=(n.indexOf(o[l])+1)/(u+1),c=!0):r>=o[l]&&(r<o[l+1]||l===i-1)&&(f=(n.indexOf(o[l])+1+(r-o[l])/(o[l+1]-o[l]))/(u+1),c=!0),l++;return Math.floor(f*a)/a},or.INC=function(n,r,t){if(t=void 0===t?3:t,b(n=M(h(n)),r=d(r),t=d(t)))return e;n=n.sort((function(n,r){return n-r}));for(var o=Rn.apply(null,n),u=n.length,i=o.length,a=Math.pow(10,t),f=0,c=!1,l=0;!c&&l<i;)r===o[l]?(f=n.indexOf(o[l])/(u-1),c=!0):r>=o[l]&&(r<o[l+1]||l===i-1)&&(f=(n.indexOf(o[l])+(r-o[l])/(o[l+1]-o[l]))/(u-1),c=!0),l++;return Math.floor(f*a)/a};var ur={};ur.DIST=function(n,r,t){return b(n=d(n),r=d(r))?e:t?j.poisson.cdf(n,r):j.poisson.pdf(n,r)};var ir={EXC:function(n,r){if(b(n=M(h(n)),r=d(r)))return e;switch(r){case 1:return er.EXC(n,.25);case 2:return er.EXC(n,.5);case 3:return er.EXC(n,.75);default:return i}},INC:function(n,r){if(b(n=M(h(n)),r=d(r)))return e;switch(r){case 1:return er.INC(n,.25);case 2:return er.INC(n,.5);case 3:return er.INC(n,.75);default:return i}}},ar={};function fr(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=j.mean(n),t=n.length,e=0,o=0;o<t;o++)e+=Math.pow(n[o]-r,3);return t*e/((t-1)*(t-2)*Math.pow(j.stdev(n,!0),3))}function cr(n,r){return b(n=M(h(n)),r=d(r))?n:n.sort((function(n,r){return n-r}))[r-1]}ar.AVG=function(n,r,t){if(b(n=d(n),r=M(h(r))))return e;for(var o=(t=t||!1)?function(n,r){return n-r}:function(n,r){return r-n},u=(r=(r=h(r)).sort(o)).length,i=0,a=0;a<u;a++)r[a]===n&&i++;return i>1?(2*r.indexOf(n)+i+1)/2:r.indexOf(n)+1},ar.EQ=function(n,r,t){if(b(n=d(n),r=M(h(r))))return e;var o=(t=t||!1)?function(n,r){return n-r}:function(n,r){return r-n};return(r=r.sort(o)).indexOf(n)+1},fr.P=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=j.mean(n),t=n.length,e=0,o=0,u=0;u<t;u++)o+=Math.pow(n[u]-r,3),e+=Math.pow(n[u]-r,2);return e/=t,(o/=t)/Math.pow(e,1.5)};var lr={};lr.P=function(){var n=hr.P.apply(this,arguments),r=Math.sqrt(n);return isNaN(r)&&(r=i),r},lr.S=function(){var n=hr.S.apply(this,arguments),r=Math.sqrt(n);return r};var sr={};sr.DIST=function(n,r,t){return 1!==t&&2!==t?i:1===t?sr.DIST.RT(n,r):sr.DIST["2T"](n,r)},sr.DIST["2T"]=function(n,r){return 2!==arguments.length?a:n<0||r<1?i:"number"!=typeof n||"number"!=typeof r?e:2*(1-j.studentt.cdf(n,r))},sr.DIST.RT=function(n,r){return 2!==arguments.length?a:n<0||r<1?i:"number"!=typeof n||"number"!=typeof r?e:1-j.studentt.cdf(n,r)},sr.INV=function(n,r){return b(n=d(n),r=d(r))?e:j.studentt.inv(n,r)},sr.INV["2T"]=function(n,r){return n=d(n),r=d(r),n<=0||n>1||r<1?i:b(n,r)?e:Math.abs(j.studentt.inv(n/2,r))},sr.TEST=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;var t,o=j.mean(n),u=j.mean(r),i=0,a=0;for(t=0;t<n.length;t++)i+=Math.pow(n[t]-o,2);for(t=0;t<r.length;t++)a+=Math.pow(r[t]-u,2);i/=n.length-1,a/=r.length-1;var f=Math.abs(o-u)/Math.sqrt(i/n.length+a/r.length);return sr.DIST["2T"](f,n.length+r.length-2)};var hr={};function gr(){for(var n=h(arguments),r=n.length,t=0,e=0,o=On(n),u=0;u<r;u++){var i=n[u];t+="number"==typeof i?Math.pow(i-o,2):!0===i?Math.pow(1-o,2):Math.pow(0-o,2),null!==i&&e++}return t/(e-1)}function vr(){for(var n,r=h(arguments),t=r.length,e=0,o=0,u=On(r),a=0;a<t;a++){var f=r[a];e+="number"==typeof f?Math.pow(f-u,2):!0===f?Math.pow(1-u,2):Math.pow(0-u,2),null!==f&&o++}return n=e/o,isNaN(n)&&(n=i),n}hr.P=function(){for(var n,r=v(h(arguments)),t=r.length,e=0,o=xn(r),u=0;u<t;u++)e+=Math.pow(r[u]-o,2);return n=e/t,isNaN(n)&&(n=i),n},hr.S=function(){for(var n=v(h(arguments)),r=n.length,t=0,e=xn(n),o=0;o<r;o++)t+=Math.pow(n[o]-e,2);return t/(r-1)};var pr={DIST:function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t))?e:o?1-Math.exp(-Math.pow(n/t,r)):Math.pow(n,r-1)*Math.exp(-Math.pow(n/t,r))*r/Math.pow(t,r)}},mr={};function dr(n,r,t){var e=I(n=d(n),r=d(r),t=d(t));if(e)return e;if(0===r)return 0;r=Math.abs(r);var o=-Math.floor(Math.log(r)/Math.log(10));return n>=0?Tr(Math.ceil(n/r)*r,o):0===t?-Tr(Math.floor(Math.abs(n)/r)*r,o):-Tr(Math.ceil(Math.abs(n)/r)*r,o)}function Er(n,r){var t=I(n=d(n),r=d(r));return t||(n<r?i:Nr(n)/(Nr(r)*Nr(n-r)))}mr.TEST=function(n,r,t){if(b(n=M(h(n)),r=d(r)))return e;t=t||lr.S(n);var o=n.length;return 1-rr.S.DIST((xn(n)-r)/(t/Math.sqrt(o)),!0)},dr.MATH=dr,dr.PRECISE=dr;var Mr=[];function Nr(n){if((n=d(n))instanceof Error)return n;var r=Math.floor(n);return 0===r||1===r?1:(Mr[r]>0||(Mr[r]=Nr(r-1)*r),Mr[r])}function wr(n,r){var t=I(n=d(n),r=d(r));if(t)return t;if(0===r)return 0;if(!(n>=0&&r>0||n<=0&&r<0))return i;r=Math.abs(r);var e=-Math.floor(Math.log(r)/Math.log(10));return n>=0?Tr(Math.floor(n/r)*r,e):-Tr(Math.ceil(Math.abs(n)/r),e)}wr.MATH=function(n,r,t){if(r instanceof Error)return r;r=void 0===r?0:r;var e=I(n=d(n),r=d(r),t=d(t));if(e)return e;if(0===r)return 0;r=r?Math.abs(r):1;var o=-Math.floor(Math.log(r)/Math.log(10));return n>=0?Tr(Math.floor(n/r)*r,o):0===t||void 0===t?-Tr(Math.ceil(Math.abs(n)/r)*r,o):-Tr(Math.floor(Math.abs(n)/r)*r,o)},wr.PRECISE=wr.MATH;var Ir={CEILING:dr};function yr(n,r){var t=I(n=d(n),r=d(r));if(t)return t;if(0===n&&0===r)return i;var e=Math.pow(n,r);return isNaN(e)?i:e}function br(){var n=h(arguments),r=n.filter((function(n){return null!=n}));if(0===r.length)return 0;var t=M(r);if(t instanceof Error)return t;for(var e=1,o=0;o<t.length;o++)e*=t[o];return e}function Tr(n,r){var t=I(n=d(n),r=d(r));return t||Math.round(n*Math.pow(10,r))/Math.pow(10,r)}function Sr(){var n=0;return D(g(arguments),(function(r){if(n instanceof Error)return!1;if(r instanceof Error)n=r;else if("number"==typeof r)n+=r;else if("string"==typeof r){var t=parseFloat(r);!isNaN(t)&&(n+=t)}else if(Array.isArray(r)){var e=Sr.apply(null,r);e instanceof Error?n=e:n+=e}})),n}var Ar=Pn.DIST,Dr=Pn.INV,Rr=Ln.DIST,Cr=dr.MATH,xr=dr.PRECISE,Or=qn.DIST,Pr=qn.DIST.RT,Lr=qn.INV,qr=qn.INV.RT,Ur=qn.TEST,Fr=Gn.P,_r=Gn.P,Vr=Gn.S,Gr=Ln.INV,kr=tn.PRECISE,Xr=rn.PRECISE,Yr=kn.DIST,Hr=Xn.DIST,jr=Xn.DIST.RT,Br=Xn.INV,zr=Xn.INV.RT,Kr=wr.MATH,Wr=wr.PRECISE,Qr=Xn.TEST,$r=Hn.DIST,Zr=Hn.INV,Jr=jn.PRECISE,nt=Bn.DIST,rt=Wn.INV,tt=Wn.DIST,et=Wn.INV,ot=Jn.MULT,ut=Jn.SNGL,it=nr.DIST,at=F.INTL,ft=rr.DIST,ct=rr.INV,lt=rr.S.DIST,st=rr.S.INV,ht=er.EXC,gt=er.INC,vt=or.EXC,pt=or.INC,mt=ur.DIST,dt=ir.EXC,Et=ir.INC,Mt=ar.AVG,Nt=ar.EQ,wt=fr.P,It=lr.P,yt=lr.S,bt=sr.DIST,Tt=sr.DIST.RT,St=sr.INV,At=sr.TEST,Dt=hr.P,Rt=hr.S,Ct=pr.DIST,xt=_.INTL,Ot=mr.TEST;function Pt(n){var r=[];return D(n,(function(n){n&&r.push(n)})),r}function Lt(n,r){var t=null;return D(n,(function(n,e){if(n[0]===r)return t=e,!1})),null==t?e:t}function qt(n,r){for(var t={},e=1;e<n[0].length;++e)t[e]=!0;for(var o=r[0].length,u=1;u<r.length;++u)r[u].length>o&&(o=r[u].length);for(var i=1;i<n.length;++i)for(var a=1;a<n[i].length;++a){for(var f=!1,c=!1,l=0;l<r.length;++l){var s=r[l];if(!(s.length<o)){var h=s[0];if(n[i][0]===h){c=!0;for(var g=1;g<s.length;++g){if(!f)if(void 0===s[g]||"*"===s[g])f=!0;else{var v=wn(s[g]+""),p=[Mn(n[i][a],En)].concat(v);f=In(p)}}}}}c&&(t[a]=t[a]&&f)}for(var m=[],d=0;d<n[0].length;++d)t[d]&&m.push(d-1);return m}function Ut(n){return n&&n.getTime&&!isNaN(n.getTime())}function Ft(n){return n instanceof Date?n:new Date(n)}function _t(n,r,t,o,u){if(o=o||0,u=u||0,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u)))return e;var i;if(0===n)i=o+t*r;else{var a=Math.pow(1+n,r);i=1===u?o*a+t*(1+n)*(a-1)/n:o*a+t*(a-1)/n}return-i}function Vt(n,r,t,o,u,i){if(u=u||0,i=i||0,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u),i=d(i)))return e;var a=kt(n,t,o,u,i);return(1===r?1===i?0:-o:1===i?_t(n,r-2,a,o,1)-a:_t(n,r-1,a,o,0))*n}function Gt(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=n[0],t=0,e=1;e<n.length;e++)t+=n[e]/Math.pow(1+r,e);return t}function kt(n,r,t,o,u){if(o=o||0,u=u||0,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u)))return e;var i;if(0===n)i=(t+o)/r;else{var a=Math.pow(1+n,r);i=1===u?(o*n/(a-1)+t*n/(1-1/a))/(1+n):o*n/(a-1)+t*n/(1-1/a)}return-i}function Xt(n,r,t,e){if(!r||!t)return a;e=!(0===e||!1===e);for(var u=a,i="number"==typeof n,f=!1,c=0;c<r.length;c++){var l=r[c];if(l[0]===n){u=t<l.length+1?l[t-1]:o;break}!f&&(i&&e&&l[0]<=n||e&&"string"==typeof l[0]&&l[0].localeCompare(n)<0)&&(u=t<l.length+1?l[t-1]:o),i&&l[0]>n&&(f=!0)}return u}n.ABS=function(n){return(n=d(n))instanceof Error?n:Math.abs(n)},n.ACCRINT=function(n,r,t,o,u,a,f){return n=Ft(n),r=Ft(r),t=Ft(t),Ut(n)&&Ut(r)&&Ut(t)?o<=0||u<=0||-1===[1,2,4].indexOf(a)||-1===[0,1,2,3,4].indexOf(f)||t<=n?i:(u=u||0)*o*k(n,t,f=f||0):e},n.ACCRINTM=function(){throw new Error("ACCRINTM is not implemented")},n.ACOS=function(n){if((n=d(n))instanceof Error)return n;var r=Math.acos(n);return isNaN(r)&&(r=i),r},n.ACOSH=function(n){if((n=d(n))instanceof Error)return n;var r=Math.log(n+Math.sqrt(n*n-1));return isNaN(r)&&(r=i),r},n.ACOT=function(n){return(n=d(n))instanceof Error?n:Math.atan(1/n)},n.ACOTH=function(n){if((n=d(n))instanceof Error)return n;var r=.5*Math.log((n+1)/(n-1));return isNaN(r)&&(r=i),r},n.ADD=function(n,r){if(2!==arguments.length)return a;var t=I(n=d(n),r=d(r));return t||n+r},n.AGGREGATE=function(n,r,t,o){if(b(n=d(n),d(n)))return e;switch(n){case 1:return xn(t);case 2:return Fn(t);case 3:return _n(t);case 4:return Qn(t);case 5:return Zn(t);case 6:return br(t);case 7:return lr.S(t);case 8:return lr.P(t);case 9:return Sr(t);case 10:return hr.S(t);case 11:return hr.P(t);case 12:return $n(t);case 13:return Jn.SNGL(t);case 14:return zn(t,o);case 15:return cr(t,o);case 16:return er.INC(t,o);case 17:return ir.INC(t,o);case 18:return er.EXC(t,o);case 19:return ir.EXC(t,o)}},n.AMORDEGRC=function(){throw new Error("AMORDEGRC is not implemented")},n.AMORLINC=function(){throw new Error("AMORLINC is not implemented")},n.AND=function(){for(var n=h(arguments),r=e,t=0;t<n.length;t++){if(n[t]instanceof Error)return n[t];void 0!==n[t]&&null!==n[t]&&"string"!=typeof n[t]&&(r===e&&(r=!0),n[t]||(r=!1))}return r},n.ARABIC=function(n){if(null==n)return 0;if(n instanceof Error)return n;if(!/^M*(?:D?C{0,3}|C[MD])(?:L?X{0,3}|X[CL])(?:V?I{0,3}|I[XV])$/.test(n))return e;var r=0;return n.replace(/[MDLV]|C[MD]?|X[CL]?|I[XV]?/g,(function(n){r+={M:1e3,CM:900,D:500,CD:400,C:100,XC:90,L:50,XL:40,X:10,IX:9,V:5,IV:4,I:1}[n]})),r},n.ARGS2ARRAY=function(){return Array.prototype.slice.call(arguments,0)},n.ASC=function(){throw new Error("ASC is not implemented")},n.ASIN=function(n){if((n=d(n))instanceof Error)return n;var r=Math.asin(n);return isNaN(r)&&(r=i),r},n.ASINH=function(n){return(n=d(n))instanceof Error?n:Math.log(n+Math.sqrt(n*n+1))},n.ATAN=function(n){return(n=d(n))instanceof Error?n:Math.atan(n)},n.ATAN2=function(n,r){var t=I(n=d(n),r=d(r));return t||Math.atan2(n,r)},n.ATANH=function(n){if((n=d(n))instanceof Error)return n;var r=Math.log((1+n)/(1-n))/2;return isNaN(r)&&(r=i),r},n.AVEDEV=function(){var n=h(arguments),r=n.filter(y);if(0===r.length)return i;var t=M(r);return t instanceof Error?t:j.sum(j(t).subtract(j.mean(t)).abs()[0])/t.length},n.AVERAGE=xn,n.AVERAGEA=On,n.AVERAGEIF=function(n,r,t){if(arguments.length<=1)return a;var e=h(t=t||n),o=e.filter(y);if(t=M(o),n=h(n),t instanceof Error)return t;for(var u=0,i=0,f=void 0===r||"*"===r,c=f?null:wn(r+""),l=0;l<n.length;l++){var s=n[l];if(f)i+=t[l],u++;else{var g=[Mn(s,En)].concat(c);In(g)&&(i+=t[l],u++)}}return i/u},n.AVERAGEIFS=function(){for(var n=g(arguments),r=(n.length-1)/2,t=h(n[0]),e=0,o=0,u=0;u<t.length;u++){for(var i=!1,a=0;a<r;a++){var f=n[2*a+1][u],c=n[2*a+2],l=void 0===c||"*"===c,s=!1;if(l)s=!0;else{var v=wn(c+""),p=[Mn(f,En)].concat(v);s=In(p)}if(!s){i=!1;break}i=!0}i&&(o+=t[u],e++)}var m=o/e;return isNaN(m)?0:m},n.BAHTTEXT=function(){throw new Error("BAHTTEXT is not implemented")},n.BASE=function(n,r,t){var e=I(n=d(n),r=d(r),t=d(t));if(e)return e;if(0===r)return i;var o=n.toString(r);return new Array(Math.max(t+1-o.length,0)).join("0")+o},n.BESSELI=function(n,r){return b(n=d(n),r=d(r))?e:Y.besseli(n,r)},n.BESSELJ=function(n,r){return b(n=d(n),r=d(r))?e:Y.besselj(n,r)},n.BESSELK=function(n,r){return b(n=d(n),r=d(r))?e:Y.besselk(n,r)},n.BESSELY=function(n,r){return b(n=d(n),r=d(r))?e:Y.bessely(n,r)},n.BETA=Pn,n.BETADIST=Ar,n.BETAINV=Dr,n.BIN2DEC=function(n){if(!J(n))return i;var r=parseInt(n,2),t=n.toString();return 10===t.length&&"1"===t.substring(0,1)?parseInt(t.substring(1),2)-512:r},n.BIN2HEX=function(n,r){if(!J(n))return i;var t=n.toString();if(10===t.length&&"1"===t.substring(0,1))return(0xfffffffe00+parseInt(t.substring(1),2)).toString(16);var o=parseInt(n,2).toString(16);return void 0===r?o:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=o.length?Q("0",r-o.length)+o:i},n.BIN2OCT=function(n,r){if(!J(n))return i;var t=n.toString();if(10===t.length&&"1"===t.substring(0,1))return(1073741312+parseInt(t.substring(1),2)).toString(8);var o=parseInt(n,2).toString(8);return void 0===r?o:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=o.length?Q("0",r-o.length)+o:i},n.BINOM=Ln,n.BINOMDIST=Rr,n.BITAND=function(n,r){return b(n=d(n),r=d(r))?e:n<0||r<0||Math.floor(n)!==n||Math.floor(r)!==r||n>0xffffffffffff||r>0xffffffffffff?i:n&r},n.BITLSHIFT=function(n,r){return b(n=d(n),r=d(r))?e:n<0||Math.floor(n)!==n||n>0xffffffffffff||Math.abs(r)>53?i:r>=0?n<<r:n>>-r},n.BITOR=function(n,r){return b(n=d(n),r=d(r))?e:n<0||r<0||Math.floor(n)!==n||Math.floor(r)!==r||n>0xffffffffffff||r>0xffffffffffff?i:n|r},n.BITRSHIFT=function(n,r){return b(n=d(n),r=d(r))?e:n<0||Math.floor(n)!==n||n>0xffffffffffff||Math.abs(r)>53?i:r>=0?n>>r:n<<-r},n.BITXOR=function(n,r){return b(n=d(n),r=d(r))?e:n<0||r<0||Math.floor(n)!==n||Math.floor(r)!==r||n>0xffffffffffff||r>0xffffffffffff?i:n^r},n.CEILING=dr,n.CEILINGMATH=Cr,n.CEILINGPRECISE=xr,n.CELL=function(){throw new Error("CELL is not implemented")},n.CHAR=B,n.CHIDIST=Or,n.CHIDISTRT=Pr,n.CHIINV=Lr,n.CHIINVRT=qr,n.CHISQ=qn,n.CHITEST=Ur,n.CHOOSE=function(){if(arguments.length<2)return a;var n=arguments[0];return n<1||n>254||arguments.length<n+1?e:arguments[n]},n.CLEAN=function(n){return b(n)?n:(n=n||"").replace(/[\0-\x1F]/g,"")},n.CODE=z,n.COLUMN=function(n,r){return 2!==arguments.length?a:r<0?i:n instanceof Array&&"number"==typeof r?0!==n.length?j.col(n,r):void 0:e},n.COLUMNS=function(n){return 1!==arguments.length?a:n instanceof Array?0===n.length?0:j.cols(n):e},n.COMBIN=Er,n.COMBINA=function(n,r){var t=I(n=d(n),r=d(r));return t||(n<r?i:0===n&&0===r?1:Er(n+r-1,n-1))},n.COMPLEX=nn,n.CONCAT=W,n.CONCATENATE=K,n.CONFIDENCE=Un,n.CONVERT=function(n,r,t){if((n=d(n))instanceof Error)return n;for(var e,o=[["a.u. of action","?",null,"action",!1,!1,105457168181818e-48],["a.u. of charge","e",null,"electric_charge",!1,!1,160217653141414e-33],["a.u. of energy","Eh",null,"energy",!1,!1,435974417757576e-32],["a.u. of length","a?",null,"length",!1,!1,529177210818182e-25],["a.u. of mass","m?",null,"mass",!1,!1,910938261616162e-45],["a.u. of time","?/Eh",null,"time",!1,!1,241888432650516e-31],["admiralty knot","admkn",null,"speed",!1,!0,.514773333],["ampere","A",null,"electric_current",!0,!1,1],["ampere per meter","A/m",null,"magnetic_field_intensity",!0,!1,1],["ångström","Å",["ang"],"length",!1,!0,1e-10],["are","ar",null,"area",!1,!0,100],["astronomical unit","ua",null,"length",!1,!1,149597870691667e-25],["bar","bar",null,"pressure",!1,!1,1e5],["barn","b",null,"area",!1,!1,1e-28],["becquerel","Bq",null,"radioactivity",!0,!1,1],["bit","bit",["b"],"information",!1,!0,1],["btu","BTU",["btu"],"energy",!1,!0,1055.05585262],["byte","byte",null,"information",!1,!0,8],["candela","cd",null,"luminous_intensity",!0,!1,1],["candela per square metre","cd/m?",null,"luminance",!0,!1,1],["coulomb","C",null,"electric_charge",!0,!1,1],["cubic ångström","ang3",["ang^3"],"volume",!1,!0,1e-30],["cubic foot","ft3",["ft^3"],"volume",!1,!0,.028316846592],["cubic inch","in3",["in^3"],"volume",!1,!0,16387064e-12],["cubic light-year","ly3",["ly^3"],"volume",!1,!0,846786664623715e-61],["cubic metre","m?",null,"volume",!0,!0,1],["cubic mile","mi3",["mi^3"],"volume",!1,!0,4168181825.44058],["cubic nautical mile","Nmi3",["Nmi^3"],"volume",!1,!0,6352182208],["cubic Pica","Pica3",["Picapt3","Pica^3","Picapt^3"],"volume",!1,!0,7.58660370370369e-8],["cubic yard","yd3",["yd^3"],"volume",!1,!0,.764554857984],["cup","cup",null,"volume",!1,!0,.0002365882365],["dalton","Da",["u"],"mass",!1,!1,166053886282828e-41],["day","d",["day"],"time",!1,!0,86400],["degree","°",null,"angle",!1,!1,.0174532925199433],["degrees Rankine","Rank",null,"temperature",!1,!0,.555555555555556],["dyne","dyn",["dy"],"force",!1,!0,1e-5],["electronvolt","eV",["ev"],"energy",!1,!0,1.60217656514141],["ell","ell",null,"length",!1,!0,1.143],["erg","erg",["e"],"energy",!1,!0,1e-7],["farad","F",null,"electric_capacitance",!0,!1,1],["fluid ounce","oz",null,"volume",!1,!0,295735295625e-16],["foot","ft",null,"length",!1,!0,.3048],["foot-pound","flb",null,"energy",!1,!0,1.3558179483314],["gal","Gal",null,"acceleration",!1,!1,.01],["gallon","gal",null,"volume",!1,!0,.003785411784],["gauss","G",["ga"],"magnetic_flux_density",!1,!0,1],["grain","grain",null,"mass",!1,!0,647989e-10],["gram","g",null,"mass",!1,!0,.001],["gray","Gy",null,"absorbed_dose",!0,!1,1],["gross registered ton","GRT",["regton"],"volume",!1,!0,2.8316846592],["hectare","ha",null,"area",!1,!0,1e4],["henry","H",null,"inductance",!0,!1,1],["hertz","Hz",null,"frequency",!0,!1,1],["horsepower","HP",["h"],"power",!1,!0,745.69987158227],["horsepower-hour","HPh",["hh","hph"],"energy",!1,!0,2684519.538],["hour","h",["hr"],"time",!1,!0,3600],["imperial gallon (U.K.)","uk_gal",null,"volume",!1,!0,.00454609],["imperial hundredweight","lcwt",["uk_cwt","hweight"],"mass",!1,!0,50.802345],["imperial quart (U.K)","uk_qt",null,"volume",!1,!0,.0011365225],["imperial ton","brton",["uk_ton","LTON"],"mass",!1,!0,1016.046909],["inch","in",null,"length",!1,!0,.0254],["international acre","uk_acre",null,"area",!1,!0,4046.8564224],["IT calorie","cal",null,"energy",!1,!0,4.1868],["joule","J",null,"energy",!0,!0,1],["katal","kat",null,"catalytic_activity",!0,!1,1],["kelvin","K",["kel"],"temperature",!0,!0,1],["kilogram","kg",null,"mass",!0,!0,1],["knot","kn",null,"speed",!1,!0,.514444444444444],["light-year","ly",null,"length",!1,!0,9460730472580800],["litre","L",["l","lt"],"volume",!1,!0,.001],["lumen","lm",null,"luminous_flux",!0,!1,1],["lux","lx",null,"illuminance",!0,!1,1],["maxwell","Mx",null,"magnetic_flux",!1,!1,1e-18],["measurement ton","MTON",null,"volume",!1,!0,1.13267386368],["meter per hour","m/h",["m/hr"],"speed",!1,!0,.00027777777777778],["meter per second","m/s",["m/sec"],"speed",!0,!0,1],["meter per second squared","m?s??",null,"acceleration",!0,!1,1],["parsec","pc",["parsec"],"length",!1,!0,0x6da012f958ee1c],["meter squared per second","m?/s",null,"kinematic_viscosity",!0,!1,1],["metre","m",null,"length",!0,!0,1],["miles per hour","mph",null,"speed",!1,!0,.44704],["millimetre of mercury","mmHg",null,"pressure",!1,!1,133.322],["minute","?",null,"angle",!1,!1,.000290888208665722],["minute","min",["mn"],"time",!1,!0,60],["modern teaspoon","tspm",null,"volume",!1,!0,5e-6],["mole","mol",null,"amount_of_substance",!0,!1,1],["morgen","Morgen",null,"area",!1,!0,2500],["n.u. of action","?",null,"action",!1,!1,105457168181818e-48],["n.u. of mass","m?",null,"mass",!1,!1,910938261616162e-45],["n.u. of speed","c?",null,"speed",!1,!1,299792458],["n.u. of time","?/(me?c??)",null,"time",!1,!1,128808866778687e-35],["nautical mile","M",["Nmi"],"length",!1,!0,1852],["newton","N",null,"force",!0,!0,1],["œrsted","Oe ",null,"magnetic_field_intensity",!1,!1,79.5774715459477],["ohm","Ω",null,"electric_resistance",!0,!1,1],["ounce mass","ozm",null,"mass",!1,!0,.028349523125],["pascal","Pa",null,"pressure",!0,!1,1],["pascal second","Pa?s",null,"dynamic_viscosity",!0,!1,1],["pferdestärke","PS",null,"power",!1,!0,735.49875],["phot","ph",null,"illuminance",!1,!1,1e-4],["pica (1/6 inch)","pica",null,"length",!1,!0,.00035277777777778],["pica (1/72 inch)","Pica",["Picapt"],"length",!1,!0,.00423333333333333],["poise","P",null,"dynamic_viscosity",!1,!1,.1],["pond","pond",null,"force",!1,!0,.00980665],["pound force","lbf",null,"force",!1,!0,4.4482216152605],["pound mass","lbm",null,"mass",!1,!0,.45359237],["quart","qt",null,"volume",!1,!0,.000946352946],["radian","rad",null,"angle",!0,!1,1],["second","?",null,"angle",!1,!1,484813681109536e-20],["second","s",["sec"],"time",!0,!0,1],["short hundredweight","cwt",["shweight"],"mass",!1,!0,45.359237],["siemens","S",null,"electrical_conductance",!0,!1,1],["sievert","Sv",null,"equivalent_dose",!0,!1,1],["slug","sg",null,"mass",!1,!0,14.59390294],["square ångström","ang2",["ang^2"],"area",!1,!0,1e-20],["square foot","ft2",["ft^2"],"area",!1,!0,.09290304],["square inch","in2",["in^2"],"area",!1,!0,64516e-8],["square light-year","ly2",["ly^2"],"area",!1,!0,895054210748189e17],["square meter","m?",null,"area",!0,!0,1],["square mile","mi2",["mi^2"],"area",!1,!0,2589988.110336],["square nautical mile","Nmi2",["Nmi^2"],"area",!1,!0,3429904],["square Pica","Pica2",["Picapt2","Pica^2","Picapt^2"],"area",!1,!0,1792111111111e-17],["square yard","yd2",["yd^2"],"area",!1,!0,.83612736],["statute mile","mi",null,"length",!1,!0,1609.344],["steradian","sr",null,"solid_angle",!0,!1,1],["stilb","sb",null,"luminance",!1,!1,1e-4],["stokes","St",null,"kinematic_viscosity",!1,!1,1e-4],["stone","stone",null,"mass",!1,!0,6.35029318],["tablespoon","tbs",null,"volume",!1,!0,147868e-10],["teaspoon","tsp",null,"volume",!1,!0,492892e-11],["tesla","T",null,"magnetic_flux_density",!0,!0,1],["thermodynamic calorie","c",null,"energy",!1,!0,4.184],["ton","ton",null,"mass",!1,!0,907.18474],["tonne","t",null,"mass",!1,!1,1e3],["U.K. pint","uk_pt",null,"volume",!1,!0,.00056826125],["U.S. bushel","bushel",null,"volume",!1,!0,.03523907],["U.S. oil barrel","barrel",null,"volume",!1,!0,.158987295],["U.S. pint","pt",["us_pt"],"volume",!1,!0,.000473176473],["U.S. survey mile","survey_mi",null,"length",!1,!0,1609.347219],["U.S. survey/statute acre","us_acre",null,"area",!1,!0,4046.87261],["volt","V",null,"voltage",!0,!1,1],["watt","W",null,"power",!0,!0,1],["watt-hour","Wh",["wh"],"energy",!1,!0,3600],["weber","Wb",null,"magnetic_flux",!0,!1,1],["yard","yd",null,"length",!1,!0,.9144],["year","yr",null,"time",!1,!0,31557600]],u={Yi:["yobi",80,12089258196146292e8,"Yi","yotta"],Zi:["zebi",70,11805916207174113e5,"Zi","zetta"],Ei:["exbi",60,0x1000000000000000,"Ei","exa"],Pi:["pebi",50,0x4000000000000,"Pi","peta"],Ti:["tebi",40,1099511627776,"Ti","tera"],Gi:["gibi",30,1073741824,"Gi","giga"],Mi:["mebi",20,1048576,"Mi","mega"],ki:["kibi",10,1024,"ki","kilo"]},i={Y:["yotta",1e24,"Y"],Z:["zetta",1e21,"Z"],E:["exa",1e18,"E"],P:["peta",1e15,"P"],T:["tera",1e12,"T"],G:["giga",1e9,"G"],M:["mega",1e6,"M"],k:["kilo",1e3,"k"],h:["hecto",100,"h"],e:["dekao",10,"e"],d:["deci",.1,"d"],c:["centi",.01,"c"],m:["milli",.001,"m"],u:["micro",1e-6,"u"],n:["nano",1e-9,"n"],p:["pico",1e-12,"p"],f:["femto",1e-15,"f"],a:["atto",1e-18,"a"],z:["zepto",1e-21,"z"],y:["yocto",1e-24,"y"]},f=null,c=null,l=r,s=t,h=1,g=1,v=0;v<o.length;v++)e=null===o[v][2]?[]:o[v][2],(o[v][1]===l||e.indexOf(l)>=0)&&(f=o[v]),(o[v][1]===s||e.indexOf(s)>=0)&&(c=o[v]);if(null===f){var p=u[r.substring(0,2)],m=i[r.substring(0,1)];"da"===r.substring(0,2)&&(m=["dekao",10,"da"]),p?(h=p[2],l=r.substring(2)):m&&(h=m[1],l=r.substring(m[2].length));for(var E=0;E<o.length;E++)e=null===o[E][2]?[]:o[E][2],(o[E][1]===l||e.indexOf(l)>=0)&&(f=o[E])}if(null===c){var M=u[t.substring(0,2)],N=i[t.substring(0,1)];"da"===t.substring(0,2)&&(N=["dekao",10,"da"]),M?(g=M[2],s=t.substring(2)):N&&(g=N[1],s=t.substring(N[2].length));for(var w=0;w<o.length;w++)e=null===o[w][2]?[]:o[w][2],(o[w][1]===s||e.indexOf(s)>=0)&&(c=o[w])}return null===f||null===c||f[3]!==c[3]?a:n*f[6]*h/(c[6]*g)},n.CORREL=function(n,r){return b(n=M(h(n)),r=M(h(r)))?e:j.corrcoeff(n,r)},n.COS=function(n){return(n=d(n))instanceof Error?n:Math.cos(n)},n.COSH=function(n){return(n=d(n))instanceof Error?n:(Math.exp(n)+Math.exp(-n))/2},n.COT=function(n){return(n=d(n))instanceof Error?n:0===n?t:1/Math.tan(n)},n.COTH=function(n){if((n=d(n))instanceof Error)return n;if(0===n)return t;var r=Math.exp(2*n);return(r+1)/(r-1)},n.COUNT=Fn,n.COUNTA=_n,n.COUNTBLANK=Vn,n.COUNTIF=function(n,r){if(n=h(n),void 0===r||"*"===r)return n.length;for(var t=0,e=wn(r+""),o=0;o<n.length;o++){var u=[Mn(n[o],En)].concat(e);In(u)&&t++}return t},n.COUNTIFS=function(){for(var n=g(arguments),r=new Array(h(n[0]).length),t=0;t<r.length;t++)r[t]=!0;for(var e=0;e<n.length;e+=2){var o=h(n[e]),u=n[e+1],i=void 0===u||"*"===u;if(!i)for(var a=wn(u+""),f=0;f<o.length;f++){var c=o[f],l=[Mn(c,En)].concat(a);r[f]=r[f]&&In(l)}}for(var s=0,v=0;v<r.length;v++)r[v]&&s++;return s},n.COUNTIN=function(n,r){var t=0;n=h(n);for(var e=0;e<n.length;e++)n[e]===r&&t++;return t},n.COUNTUNIQUE=function(){return Rn.apply(null,h(arguments)).length},n.COUPDAYBS=function(){throw new Error("COUPDAYBS is not implemented")},n.COUPDAYS=function(){throw new Error("COUPDAYS is not implemented")},n.COUPDAYSNC=function(){throw new Error("COUPDAYSNC is not implemented")},n.COUPNCD=function(){throw new Error("COUPNCD is not implemented")},n.COUPNUM=function(){throw new Error("COUPNUM is not implemented")},n.COUPPCD=function(){throw new Error("COUPPCD is not implemented")},n.COVAR=Fr,n.COVARIANCE=Gn,n.COVARIANCEP=_r,n.COVARIANCES=Vr,n.CRITBINOM=Gr,n.CSC=function(n){return(n=d(n))instanceof Error?n:0===n?t:1/Math.sin(n)},n.CSCH=function(n){return(n=d(n))instanceof Error?n:0===n?t:2/(Math.exp(n)-Math.exp(-n))},n.CUMIPMT=function(n,r,t,o,u,a){if(b(n=d(n),r=d(r),t=d(t)))return e;if(n<=0||r<=0||t<=0)return i;if(o<1||u<1||o>u)return i;if(0!==a&&1!==a)return i;var f=kt(n,r,t,0,a),c=0;1===o&&(0===a&&(c=-t),o++);for(var l=o;l<=u;l++)c+=1===a?_t(n,l-2,f,t,1)-f:_t(n,l-1,f,t,0);return c*=n},n.CUMPRINC=function(n,r,t,o,u,a){if(b(n=d(n),r=d(r),t=d(t)))return e;if(n<=0||r<=0||t<=0)return i;if(o<1||u<1||o>u)return i;if(0!==a&&1!==a)return i;var f=kt(n,r,t,0,a),c=0;1===o&&(c=0===a?f+t*n:f,o++);for(var l=o;l<=u;l++)c+=a>0?f-(_t(n,l-2,f,t,1)-f)*n:f-_t(n,l-1,f,t,0)*n;return c},n.DATE=function(n,r,t){var o;return b(n=d(n),r=d(r),t=d(t))?o=e:(o=new Date(n,r-1,t)).getFullYear()<0&&(o=i),o},n.DATEDIF=function(n,r,t){t=t.toUpperCase(),n=N(n),r=N(r);var e,o=n.getFullYear(),u=n.getMonth(),i=n.getDate(),a=r.getFullYear(),f=r.getMonth(),c=r.getDate();switch(t){case"Y":e=Math.floor(k(n,r));break;case"D":e=L(r,n);break;case"M":e=f-u+12*(a-o),c<i&&e--;break;case"MD":i<=c?e=c-i:(0===f?(n.setFullYear(a-1),n.setMonth(12)):(n.setFullYear(a),n.setMonth(f-1)),e=L(r,n));break;case"YM":e=f-u+12*(a-o),c<i&&e--,e%=12;break;case"YD":f>u||f===u&&c<i?n.setFullYear(a):n.setFullYear(a-1),e=L(r,n)}return e},n.DATEVALUE=function(n){if("string"!=typeof n)return e;var r=Date.parse(n);return isNaN(r)?e:new Date(n)},n.DAVERAGE=function(n,r,o){if(isNaN(r)&&"string"!=typeof r)return e;var u=qt(n,o),i=[];if("string"==typeof r){var a=Lt(n,r);i=A(n[a])}else i=A(n[r]);var f=0;return D(u,(function(n){f+=i[n]})),0===u.length?t:f/u.length},n.DAY=function(n){var r=N(n);return r instanceof Error?r:r.getDate()},n.DAYS=L,n.DAYS360=q,n.DB=function(n,r,t,o,u){if(u=void 0===u?12:u,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u)))return e;if(n<0||r<0||t<0||o<0)return i;if(-1===[1,2,3,4,5,6,7,8,9,10,11,12].indexOf(u))return i;if(o>t)return i;if(r>=n)return 0;for(var a=(1-Math.pow(r/n,1/t)).toFixed(3),f=n*a*u/12,c=f,l=0,s=o===t?t-1:o,h=2;h<=s;h++)c+=l=(n-c)*a;return 1===o?f:o===t?(n-c)*a:l},n.DBCS=function(){throw new Error("DBCS is not implemented")},n.DCOUNT=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),Fn(a)},n.DCOUNTA=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),_n(a)},n.DDB=function(n,r,t,o,u){if(u=void 0===u?2:u,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u)))return e;if(n<0||r<0||t<0||o<0||u<=0)return i;if(o>t)return i;if(r>=n)return 0;for(var a=0,f=0,c=1;c<=o;c++)a+=f=Math.min(u/t*(n-a),n-r-a);return f},n.DEC2BIN=function(n,r){if((n=d(n))instanceof Error)return n;if(!/^-?[0-9]{1,3}$/.test(n)||n<-512||n>511)return i;if(n<0)return"1"+Q("0",9-(512+n).toString(2).length)+(512+n).toString(2);var t=parseInt(n,10).toString(2);return void 0===r?t:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=t.length?Q("0",r-t.length)+t:i},n.DEC2HEX=function(n,r){if((n=d(n))instanceof Error)return n;if(!/^-?[0-9]{1,12}$/.test(n)||n<-549755813888||n>549755813887)return i;if(n<0)return(1099511627776+n).toString(16);var t=parseInt(n,10).toString(16);return void 0===r?t:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=t.length?Q("0",r-t.length)+t:i},n.DEC2OCT=function(n,r){if((n=d(n))instanceof Error)return n;if(!/^-?[0-9]{1,9}$/.test(n)||n<-536870912||n>536870911)return i;if(n<0)return(1073741824+n).toString(8);var t=parseInt(n,10).toString(8);return void 0===r?t:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=t.length?Q("0",r-t.length)+t:i},n.DECIMAL=function(n,r){if(arguments.length<1)return e;var t=I(n=d(n),r=d(r));return t||(0===r?i:parseInt(n,r))},n.DEGREES=function(n){return(n=d(n))instanceof Error?n:180*n/Math.PI},n.DELTA=function(n,r){return r=void 0===r?0:r,b(n=d(n),r=d(r))?e:n===r?1:0},n.DEVSQ=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=j.mean(n),t=0,e=0;e<n.length;e++)t+=Math.pow(n[e]-r,2);return t},n.DGET=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];return u=A("string"==typeof r?n[Lt(n,r)]:n[r]),0===o.length?e:o.length>1?i:u[o[0]]},n.DISC=function(){throw new Error("DISC is not implemented")},n.DIVIDE=function(n,r){if(2!==arguments.length)return a;var e=I(n=d(n),r=d(r));return e||(0===r?t:n/r)},n.DMAX=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=u[o[0]];return D(o,(function(n){a<u[n]&&(a=u[n])})),a},n.DMIN=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=u[o[0]];return D(o,(function(n){a>u[n]&&(a=u[n])})),a},n.DOLLAR=function(){throw new Error("DOLLAR is not implemented")},n.DOLLARDE=function(n,r){if(b(n=d(n),r=d(r)))return e;if(r<0)return i;if(r>=0&&r<1)return t;r=parseInt(r,10);var o=parseInt(n,10);o+=n%1*Math.pow(10,Math.ceil(Math.log(r)/Math.LN10))/r;var u=Math.pow(10,Math.ceil(Math.log(r)/Math.LN2)+1);return o=Math.round(o*u)/u},n.DOLLARFR=function(n,r){if(b(n=d(n),r=d(r)))return e;if(r<0)return i;if(r>=0&&r<1)return t;r=parseInt(r,10);var o=parseInt(n,10);return o+=n%1*Math.pow(10,-Math.ceil(Math.log(r)/Math.LN10))*r},n.DPRODUCT=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];D(o,(function(n){a.push(u[n])})),a=Pt(a);var f=1;return D(a,(function(n){f*=n})),f},n.DSTDEV=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),a=Pt(a),lr.S(a)},n.DSTDEVP=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),a=Pt(a),lr.P(a)},n.DSUM=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),Sr(a)},n.DURATION=function(){throw new Error("DURATION is not implemented")},n.DVAR=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),hr.S(a)},n.DVARP=function(n,r,t){if(isNaN(r)&&"string"!=typeof r)return e;var o=qt(n,t),u=[];if("string"==typeof r){var i=Lt(n,r);u=A(n[i])}else u=A(n[r]);var a=[];return D(o,(function(n){a.push(u[n])})),hr.P(a)},n.E=function(){return Math.E},n.EDATE=function(n,r){return(n=N(n))instanceof Error?n:isNaN(r)?e:(r=parseInt(r,10),n.setMonth(n.getMonth()+r),n)},n.EFFECT=function(n,r){return b(n=d(n),r=d(r))?e:n<=0||r<1?i:(r=parseInt(r,10),Math.pow(1+n/r,r)-1)},n.EOMONTH=function(n,r){return(n=N(n))instanceof Error?n:isNaN(r)?e:(r=parseInt(r,10),new Date(n.getFullYear(),n.getMonth()+r+1,0))},n.EQ=function(n,r){return 2!==arguments.length?a:n instanceof Error?n:r instanceof Error?r:(null===n&&(n=void 0),null===r&&(r=void 0),n===r)},n.ERF=rn,n.ERFC=tn,n.ERFCPRECISE=kr,n.ERFPRECISE=Xr,n.ERROR=yn,n.EVEN=function(n){return(n=d(n))instanceof Error?n:dr(n,-2,-1)},n.EXACT=function(n,r){if(2!==arguments.length)return a;var t=I(n,r);return t||(n=E(n))===(r=E(r))},n.EXP=function(n){return arguments.length<1?a:arguments.length>1?f:(n=d(n))instanceof Error?n:n=Math.exp(n)},n.EXPON=kn,n.EXPONDIST=Yr,n.F=Xn,n.FACT=Nr,n.FACTDOUBLE=function n(r){if((r=d(r))instanceof Error)return r;var t=Math.floor(r);return t<=0?1:t*n(t-2)},n.FALSE=function(){return!1},n.FDIST=Hr,n.FDISTRT=jr,n.FIND=function(n,r,t){if(arguments.length<2)return a;n=E(n),t=void 0===t?0:t;var o=(r=E(r)).indexOf(n,t-1);return-1===o?e:o+1},n.FINDFIELD=Lt,n.FINV=Br,n.FINVRT=zr,n.FISHER=function(n){return(n=d(n))instanceof Error?n:Math.log((1+n)/(1-n))/2},n.FISHERINV=function(n){if((n=d(n))instanceof Error)return n;var r=Math.exp(2*n);return(r-1)/(r+1)},n.FIXED=function(){throw new Error("FIXED is not implemented")},n.FLATTEN=Cn,n.FLOOR=wr,n.FLOORMATH=Kr,n.FLOORPRECISE=Wr,n.FORECAST=Yn,n.FREQUENCY=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=n.length,o=r.length,u=[],i=0;i<=o;i++){u[i]=0;for(var a=0;a<t;a++)0===i?n[a]<=r[0]&&(u[0]+=1):i<o?n[a]>r[i-1]&&n[a]<=r[i]&&(u[i]+=1):i===o&&n[a]>r[o-1]&&(u[o]+=1)}return u},n.FTEST=Qr,n.FV=_t,n.FVSCHEDULE=function(n,r){if(b(n=d(n),r=M(h(r))))return e;for(var t=r.length,o=n,u=0;u<t;u++)o*=1+r[u];return o},n.GAMMA=Hn,n.GAMMADIST=$r,n.GAMMAINV=Zr,n.GAMMALN=jn,n.GAMMALNPRECISE=Jr,n.GAUSS=function(n){return(n=d(n))instanceof Error?n:j.normal.cdf(n,0,1)-.5},n.GCD=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=n.length,t=n[0],e=t<0?-t:t,o=1;o<r;o++){for(var u=n[o],i=u<0?-u:u;e&&i;)e>i?e%=i:i%=e;e+=i}return e},n.GEOMEAN=function(){var n=M(h(arguments));return n instanceof Error?n:j.geomean(n)},n.GESTEP=function(n,r){return b(r=r||0,n=d(n))?n:n>=r?1:0},n.GROWTH=function(n,r,t,o){if((n=M(n))instanceof Error)return n;var u;if(void 0===r)for(r=[],u=1;u<=n.length;u++)r.push(u);if(void 0===t)for(t=[],u=1;u<=n.length;u++)t.push(u);if(b(r=M(r),t=M(t)))return e;void 0===o&&(o=!0);var i,a,f=n.length,c=0,l=0,s=0,h=0;for(u=0;u<f;u++){var g=r[u],v=Math.log(n[u]);c+=g,l+=v,s+=g*v,h+=g*g}c/=f,l/=f,s/=f,h/=f,o?a=l-(i=(s-c*l)/(h-c*c))*c:(i=s/h,a=0);var p=[];for(u=0;u<t.length;u++)p.push(Math.exp(a+i*t[u]));return p},n.GT=function(n,r){if(2!==arguments.length)return a;if(n instanceof Error)return n;if(r instanceof Error)return r;T(n,r)?(n=E(n),r=E(r)):(n=d(n),r=d(r));var t=I(n,r);return t||n>r},n.GTE=function(n,r){if(2!==arguments.length)return a;T(n,r)?(n=E(n),r=E(r)):(n=d(n),r=d(r));var t=I(n,r);return t||n>=r},n.HARMEAN=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=n.length,t=0,e=0;e<r;e++)t+=1/n[e];return r/t},n.HEX2BIN=function(n,r){if(!/^[0-9A-Fa-f]{1,10}$/.test(n))return i;var t=!(10!==n.length||"f"!==n.substring(0,1).toLowerCase()),o=t?parseInt(n,16)-1099511627776:parseInt(n,16);if(o<-512||o>511)return i;if(t)return"1"+Q("0",9-(512+o).toString(2).length)+(512+o).toString(2);var u=o.toString(2);return void 0===r?u:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=u.length?Q("0",r-u.length)+u:i},n.HEX2DEC=function(n){if(!/^[0-9A-Fa-f]{1,10}$/.test(n))return i;var r=parseInt(n,16);return r>=549755813888?r-1099511627776:r},n.HEX2OCT=function(n,r){if(!/^[0-9A-Fa-f]{1,10}$/.test(n))return i;var t=parseInt(n,16);if(t>536870911&&t<0xffe0000000)return i;if(t>=0xffe0000000)return(t-0xffc0000000).toString(8);var o=t.toString(8);return void 0===r?o:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=o.length?Q("0",r-o.length)+o:i},n.HLOOKUP=function(n,r,t,o){return Xt(n,(u=r)?u[0].map((function(n,r){return u.map((function(n){return n[r]}))})):e,t,o);var u},n.HOUR=function(n){return(n=N(n))instanceof Error?n:n.getHours()},n.HTML2TEXT=function(n){if(b(n))return n;var r="";return n&&(n instanceof Array?n.forEach((function(n){""!==r&&(r+="\n"),r+=n.replace(/<(?:.|\n)*?>/gm,"")})):r=n.replace(/<(?:.|\n)*?>/gm,"")),r},n.HYPGEOM=Bn,n.HYPGEOMDIST=nt,n.IF=function(n,r,t){return n instanceof Error?n:(null==(r=!(arguments.length>=2)||r)&&(r=0),null==(t=3===arguments.length&&t)&&(t=0),n?r:t)},n.IFERROR=function(n,r){return Tn(n)?r:n},n.IFNA=function(n,r){return n===a?r:n},n.IFS=function(){for(var n=0;n<arguments.length/2;n++)if(arguments[2*n])return arguments[2*n+1];return a},n.IMABS=en,n.IMAGINARY=on,n.IMARGUMENT=un,n.IMCONJUGATE=function(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",0!==t?nn(r,-t,o):n},n.IMCOS=an,n.IMCOSH=fn,n.IMCOT=function(n){return b(ln(n),on(n))?e:cn(an(n),sn(n))},n.IMCSC=function(n){return!0===n||!1===n?e:b(ln(n),on(n))?i:cn("1",sn(n))},n.IMCSCH=function(n){return!0===n||!1===n?e:b(ln(n),on(n))?i:cn("1",hn(n))},n.IMDIV=cn,n.IMEXP=function(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);o="i"===o||"j"===o?o:"i";var u=Math.exp(r);return nn(u*Math.cos(t),u*Math.sin(t),o)},n.IMLN=function(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.log(Math.sqrt(r*r+t*t)),Math.atan(t/r),o)},n.IMLOG10=function(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.log(Math.sqrt(r*r+t*t))/Math.log(10),Math.atan(t/r)/Math.log(10),o)},n.IMLOG2=function(n){var r=ln(n),t=on(n);if(b(r,t))return e;var o=n.substring(n.length-1);return o="i"===o||"j"===o?o:"i",nn(Math.log(Math.sqrt(r*r+t*t))/Math.log(2),Math.atan(t/r)/Math.log(2),o)},n.IMPOWER=function(n,r){if(b(r=d(r),ln(n),on(n)))return e;var t=n.substring(n.length-1);t="i"===t||"j"===t?t:"i";var o=Math.pow(en(n),r),u=un(n);return nn(o*Math.cos(r*u),o*Math.sin(r*u),t)},n.IMPRODUCT=function(){var n=arguments[0];if(!arguments.length)return e;for(var r=1;r<arguments.length;r++){var t=ln(n),o=on(n),u=ln(arguments[r]),i=on(arguments[r]);if(b(t,o,u,i))return e;n=nn(t*u-o*i,t*i+o*u)}return n},n.IMREAL=ln,n.IMSEC=function(n){return!0===n||!1===n||b(ln(n),on(n))?e:cn("1",an(n))},n.IMSECH=function(n){return b(ln(n),on(n))?e:cn("1",fn(n))},n.IMSIN=sn,n.IMSINH=hn,n.IMSQRT=function(n){if(b(ln(n),on(n)))return e;var r=n.substring(n.length-1);r="i"===r||"j"===r?r:"i";var t=Math.sqrt(en(n)),o=un(n);return nn(t*Math.cos(o/2),t*Math.sin(o/2),r)},n.IMSUB=function(n,r){var t=ln(n),o=on(n),u=ln(r),i=on(r);if(b(t,o,u,i))return e;var a=n.substring(n.length-1),f=r.substring(r.length-1),c="i";return("j"===a||"j"===f)&&(c="j"),nn(t-u,o-i,c)},n.IMSUM=function(){if(!arguments.length)return e;for(var n=h(arguments),r=n[0],t=1;t<n.length;t++){var o=ln(r),u=on(r),i=ln(n[t]),a=on(n[t]);if(b(o,u,i,a))return e;r=nn(o+i,u+a)}return r},n.IMTAN=function(n){return!0===n||!1===n||b(ln(n),on(n))?e:cn(sn(n),an(n))},n.INDEX=function(n,r,t){var u=I(n,r,t);if(u)return u;if(!Array.isArray(n))return e;var i=n.length>0&&!Array.isArray(n[0]);return i&&!t?(t=r,r=1):(t=t||1,r=r||1),t<0||r<0?e:i&&1===r&&t<=n.length?n[t-1]:r<=n.length&&t<=n[r-1].length?n[r-1][t-1]:o},n.INFO=function(){throw new Error("INFO is not implemented")},n.INT=function(n){return(n=d(n))instanceof Error?n:Math.floor(n)},n.INTERCEPT=function(n,r){return b(n=M(n),r=M(r))?e:n.length!==r.length?a:Yn(0,n,r)},n.INTERVAL=function(n){if("number"!=typeof n&&"string"!=typeof n)return e;n=parseInt(n,10);var r=Math.floor(n/94608e4);n%=94608e4;var t=Math.floor(n/2592e3);n%=2592e3;var o=Math.floor(n/86400);n%=86400;var u=Math.floor(n/3600);n%=3600;var i=Math.floor(n/60),a=n%=60;return"P"+(r=r>0?r+"Y":"")+(t=t>0?t+"M":"")+(o=o>0?o+"D":"")+"T"+(u=u>0?u+"H":"")+(i=i>0?i+"M":"")+(a=a>0?a+"S":"")},n.INTRATE=function(){throw new Error("INTRATE is not implemented")},n.IPMT=Vt,n.IRR=function(n,r){if(r=r||0,b(n=M(h(n)),r=d(r)))return e;for(var t=function(n,r,t){for(var e=t+1,o=n[0],u=1;u<n.length;u++)o+=n[u]/Math.pow(e,(r[u]-r[0])/365);return o},o=function(n,r,t){for(var e=t+1,o=0,u=1;u<n.length;u++){var i=(r[u]-r[0])/365;o-=i*n[u]/Math.pow(e,i+1)}return o},u=[],a=!1,f=!1,c=0;c<n.length;c++)u[c]=0===c?0:u[c-1]+365,n[c]>0&&(a=!0),n[c]<0&&(f=!0);if(!a||!f)return i;var l,s,g,v=r=void 0===r?.1:r,p=!0;do{l=v-(g=t(n,u,v))/o(n,u,v),s=Math.abs(l-v),v=l,p=s>1e-10&&Math.abs(g)>1e-10}while(p);return v},n.ISBINARY=function(n){return/^[01]{1,10}$/.test(n)},n.ISBLANK=function(n){return null===n},n.ISERR=bn,n.ISERROR=Tn,n.ISEVEN=function(n){return!(1&Math.floor(Math.abs(n)))},n.ISFORMULA=function(){throw new Error("ISFORMULA is not implemented")},n.ISLOGICAL=Sn,n.ISNA=function(n){return n===a},n.ISNONTEXT=function(n){return"string"!=typeof n},n.ISNUMBER=An,n.ISO=Ir,n.ISODD=function(n){return!!(1&Math.floor(Math.abs(n)))},n.ISOWEEKNUM=U,n.ISPMT=function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t),o=d(o))?e:o*n*(r/t-1)},n.ISREF=function(){throw new Error("ISREF is not implemented")},n.ISTEXT=Dn,n.JOIN=function(n,r){return n.join(r)},n.KURT=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=j.mean(n),t=n.length,e=0,o=0;o<t;o++)e+=Math.pow(n[o]-r,4);return t*(t+1)/((t-1)*(t-2)*(t-3))*(e/=Math.pow(j.stdev(n,!0),4))-3*(t-1)*(t-1)/((t-2)*(t-3))},n.LARGE=zn,n.LCM=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r,t,e,o,u=1;void 0!==(e=n.pop());){if(0===e)return 0;for(;e>1;){if(e%2){for(r=3,t=Math.floor(Math.sqrt(e));r<=t&&e%r;r+=2);o=r<=t?r:e}else o=2;for(e/=o,u*=o,r=n.length;r;n[--r]%o==0&&1==(n[r]/=o)&&n.splice(r,1));}}return u},n.LEFT=function(n,r){var t=I(n,r);return t||(n=E(n),(r=d(r=void 0===r?1:r))instanceof Error||"string"!=typeof n?e:n.substring(0,r))},n.LEN=function(n){if(0===arguments.length)return f;if(n instanceof Error)return n;if(Array.isArray(n))return e;var r=E(n);return r.length},n.LINEST=Kn,n.LN=function(n){return(n=d(n))instanceof Error?n:0===n?i:Math.log(n)},n.LN10=function(){return Math.log(10)},n.LN2=function(){return Math.log(2)},n.LOG=function(n,r){var t=I(n=d(n),r=d(r));return t||(0===n||0===r?i:Math.log(n)/Math.log(r))},n.LOG10=function(n){return(n=d(n))instanceof Error?n:0===n?i:Math.log(n)/Math.log(10)},n.LOG10E=function(){return Math.LOG10E},n.LOG2E=function(){return Math.LOG2E},n.LOGEST=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=0;t<n.length;t++)n[t]=Math.log(n[t]);var o=Kn(n,r);return o[0]=Math.round(1e6*Math.exp(o[0]))/1e6,o[1]=Math.round(1e6*Math.exp(o[1]))/1e6,o},n.LOGINV=rt,n.LOGNORM=Wn,n.LOGNORMDIST=tt,n.LOGNORMINV=et,n.LOOKUP=function(n,r,t){r=h(r),t=h(t);for(var e="number"==typeof n,o=a,u=0;u<r.length;u++){if(r[u]===n)return t[u];if(e&&r[u]<=n||"string"==typeof r[u]&&r[u].localeCompare(n)<0)o=t[u];else if(e&&r[u]>n)return o}return o},n.LOWER=function(n){return 1!==arguments.length?e:b(n=E(n))?n:n.toLowerCase()},n.LT=function(n,r){if(2!==arguments.length)return a;T(n,r)?(n=E(n),r=E(r)):(n=d(n),r=d(r));var t=I(n,r);return t||n<r},n.LTE=function(n,r){if(2!==arguments.length)return a;T(n,r)?(n=E(n),r=E(r)):(n=d(n),r=d(r));var t=I(n,r);return t||n<=r},n.MATCH=function(n,r,t){if(!n&&!r)return a;if(2===arguments.length&&(t=1),!(r instanceof Array))return a;if(r=h(r),-1!==t&&0!==t&&1!==t)return a;for(var e,o,u=0;u<r.length;u++)if(1===t){if(r[u]===n)return u+1;r[u]<n&&(o?r[u]>o&&(e=u+1,o=r[u]):(e=u+1,o=r[u]))}else if(0===t){if("string"==typeof n){if(n=n.replace(/\?/g,"."),r[u].toLowerCase().match(n.toLowerCase()))return u+1}else if(r[u]===n)return u+1}else if(-1===t){if(r[u]===n)return u+1;r[u]>n&&(o?r[u]<o&&(e=u+1,o=r[u]):(e=u+1,o=r[u]))}return e||a},n.MAX=Qn,n.MAXA=function(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;var t=S(n);return t=t.map((function(n){return null==n?0:n})),0===t.length?0:Math.max.apply(Math,t)},n.MDURATION=function(){throw new Error("MDURATION is not implemented")},n.MEDIAN=$n,n.MID=function(n,r,t){if(null==r)return e;if(b(r=d(r),t=d(t))||"string"!=typeof n)return t;var o=r-1,u=o+t;return n.substring(o,u)},n.MIN=Zn,n.MINA=function(){var n=h(arguments),r=I.apply(void 0,n);if(r)return r;var t=S(n);return t=t.map((function(n){return null==n?0:n})),0===t.length?0:Math.min.apply(Math,t)},n.MINUS=function(n,r){if(2!==arguments.length)return a;var t=I(n=d(n),r=d(r));return t||n-r},n.MINUTE=function(n){return(n=N(n))instanceof Error?n:n.getMinutes()},n.MIRR=function(n,r,t){if(b(n=M(h(n)),r=d(r),t=d(t)))return e;for(var o=n.length,u=[],i=[],a=0;a<o;a++)n[a]<0?u.push(n[a]):i.push(n[a]);var f=-Gt(t,i)*Math.pow(1+t,o-1),c=Gt(r,u)*(1+r);return Math.pow(f/c,1/(o-1))-1},n.MOD=function(n,r){var e=I(n=d(n),r=d(r));if(e)return e;if(0===r)return t;var o=Math.abs(n%r);return o=n<0?r-o:o,r>0?o:-o},n.MODE=Jn,n.MODEMULT=ot,n.MODESNGL=ut,n.MONTH=function(n){return(n=N(n))instanceof Error?n:n.getMonth()+1},n.MROUND=function(n,r){var t=I(n=d(n),r=d(r));return t||(n*r==0?0:n*r<0?i:Math.round(n/r)*r)},n.MULTINOMIAL=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=0,t=1,e=0;e<n.length;e++)r+=n[e],t*=Nr(n[e]);return Nr(r)/t},n.MULTIPLY=function(n,r){if(2!==arguments.length)return a;var t=I(n=d(n),r=d(r));return t||n*r},n.N=function(n){return An(n)?n:n instanceof Date?n.getTime():!0===n?1:!1===n?0:Tn(n)?n:0},n.NA=function(){return a},n.NE=function(n,r){return 2!==arguments.length?a:n instanceof Error?n:r instanceof Error?r:(null===n&&(n=void 0),null===r&&(r=void 0),n!==r)},n.NEGBINOM=nr,n.NEGBINOMDIST=it,n.NETWORKDAYS=F,n.NETWORKDAYSINTL=at,n.NOMINAL=function(n,r){return b(n=d(n),r=d(r))?e:n<=0||r<1?i:(r=parseInt(r,10),(Math.pow(n+1,1/r)-1)*r)},n.NORM=rr,n.NORMDIST=ft,n.NORMINV=ct,n.NORMSDIST=lt,n.NORMSINV=st,n.NOT=function(n){return"string"==typeof n?e:n instanceof Error?n:!n},n.NOW=function(){return new Date},n.NPER=function(n,r,t,o,u){if(u=void 0===u?0:u,o=void 0===o?0:o,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u)))return e;if(0===n)return-(t+o)/r;var i=r*(1+n*u)-o*n,a=t*n+r*(1+n*u);return Math.log(i/a)/Math.log(1+n)},n.NPV=Gt,n.NUMBERS=function(){var n=h(arguments);return n.filter((function(n){return"number"==typeof n}))},n.NUMBERVALUE=function(n,r,t){return r=void 0===r?".":r,t=void 0===t?",":t,Number(n.replace(r,".").replace(t,""))},n.OCT2BIN=function(n,r){if(!/^[0-7]{1,10}$/.test(n))return i;var t=!(10!==n.length||"7"!==n.substring(0,1)),o=t?parseInt(n,8)-1073741824:parseInt(n,8);if(o<-512||o>511)return i;if(t)return"1"+Q("0",9-(512+o).toString(2).length)+(512+o).toString(2);var u=o.toString(2);return void 0===r?u:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=u.length?Q("0",r-u.length)+u:i},n.OCT2DEC=function(n){if(!/^[0-7]{1,10}$/.test(n))return i;var r=parseInt(n,8);return r>=536870912?r-1073741824:r},n.OCT2HEX=function(n,r){if(!/^[0-7]{1,10}$/.test(n))return i;var t=parseInt(n,8);if(t>=536870912)return"ff"+(t+3221225472).toString(16);var o=t.toString(16);return void 0===r?o:isNaN(r)?e:r<0?i:(r=Math.floor(r))>=o.length?Q("0",r-o.length)+o:i},n.ODD=function(n){if((n=d(n))instanceof Error)return n;var r=Math.ceil(Math.abs(n));return r=1&r?r:r+1,n>=0?r:-r},n.ODDFPRICE=function(){throw new Error("ODDFPRICE is not implemented")},n.ODDFYIELD=function(){throw new Error("ODDFYIELD is not implemented")},n.ODDLPRICE=function(){throw new Error("ODDLPRICE is not implemented")},n.ODDLYIELD=function(){throw new Error("ODDLYIELD is not implemented")},n.OR=function(){for(var n=h(arguments),r=e,t=0;t<n.length;t++){if(n[t]instanceof Error)return n[t];void 0!==n[t]&&null!==n[t]&&"string"!=typeof n[t]&&(r===e&&(r=!1),n[t]&&(r=!0))}return r},n.PDURATION=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:n<=0?i:(Math.log(t)-Math.log(r))/Math.log(1+n)},n.PEARSON=tr,n.PERCENTILE=er,n.PERCENTILEEXC=ht,n.PERCENTILEINC=gt,n.PERCENTRANK=or,n.PERCENTRANKEXC=vt,n.PERCENTRANKINC=pt,n.PERMUT=function(n,r){return b(n=d(n),r=d(r))?e:Nr(n)/Nr(n-r)},n.PERMUTATIONA=function(n,r){return b(n=d(n),r=d(r))?e:Math.pow(n,r)},n.PHI=function(n){return(n=d(n))instanceof Error?e:Math.exp(-.5*n*n)/2.5066282746310002},n.PI=function(){return Math.PI},n.PMT=kt,n.POISSON=ur,n.POISSONDIST=mt,n.POW=function(n,r){return 2!==arguments.length?a:yr(n,r)},n.POWER=yr,n.PPMT=function(n,r,t,o,u,i){return u=u||0,i=i||0,b(n=d(n),t=d(t),o=d(o),u=d(u),i=d(i))?e:kt(n,t,o,u,i)-Vt(n,r,t,o,u,i)},n.PRICE=function(){throw new Error("PRICE is not implemented")},n.PRICEDISC=function(){throw new Error("PRICEDISC is not implemented")},n.PRICEMAT=function(){throw new Error("PRICEMAT is not implemented")},n.PROB=function(n,r,t,o){if(void 0===t)return 0;if(o=void 0===o?t:o,b(n=M(h(n)),r=M(h(r)),t=d(t),o=d(o)))return e;if(t===o)return n.indexOf(t)>=0?r[n.indexOf(t)]:0;for(var u=n.sort((function(n,r){return n-r})),i=u.length,a=0,f=0;f<i;f++)u[f]>=t&&u[f]<=o&&(a+=r[n.indexOf(u[f])]);return a},n.PRODUCT=br,n.PRONETIC=function(){throw new Error("PRONETIC is not implemented")},n.PROPER=function(n){return b(n)?n:isNaN(n)&&"number"==typeof n?e:(n=E(n)).replace(/\w\S*/g,(function(n){return n.charAt(0).toUpperCase()+n.substr(1).toLowerCase()}))},n.PV=function(n,r,t,o,u){return o=o||0,u=u||0,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u))?e:0===n?-t*r-o:((1-Math.pow(1+n,r))/n*t*(1+n*u)-o)/Math.pow(1+n,r)},n.QUARTILE=ir,n.QUARTILEEXC=dt,n.QUARTILEINC=Et,n.QUOTIENT=function(n,r){var t=I(n=d(n),r=d(r));return t||parseInt(n/r,10)},n.RADIANS=function(n){return(n=d(n))instanceof Error?n:n*Math.PI/180},n.RAND=function(){return Math.random()},n.RANDBETWEEN=function(n,r){var t=I(n=d(n),r=d(r));return t||n+Math.ceil((r-n+1)*Math.random())-1},n.RANK=ar,n.RANKAVG=Mt,n.RANKEQ=Nt,n.RATE=function(n,r,t,o,u,a){if(a=void 0===a?.01:a,o=void 0===o?0:o,u=void 0===u?0:u,b(n=d(n),r=d(r),t=d(t),o=d(o),u=d(u),a=d(a)))return e;var f=1e-10,c=a;u=u?1:0;for(var l=0;l<20;l++){if(c<=-1)return i;var s=void 0,h=void 0;if(s=Math.abs(c)<f?t*(1+n*c)+r*(1+c*u)*n+o:t*(h=Math.pow(1+c,n))+r*(1/c+u)*(h-1)+o,Math.abs(s)<f)return c;var g=void 0;if(Math.abs(c)<f)g=t*n+r*u*n;else{h=Math.pow(1+c,n);var v=n*Math.pow(1+c,n-1);g=t*v+r*(1/c+u)*v+r*(-1/(c*c))*(h-1)}c-=s/g}return c},n.RECEIVED=function(){throw new Error("RECEIVED is not implemented")},n.REFERENCE=function(n,r){if(!arguments.length)return f;try{for(var t=r.split("."),e=n,o=0;o<t.length;++o){var u=t[o];if("]"===u[u.length-1]){var i=u.indexOf("["),a=u.substring(i+1,u.length-1);e=e[u.substring(0,i)][a]}else e=e[u]}return e}catch(n){}},n.REGEXEXTRACT=function(n,r){if(arguments.length<2)return a;var t=n.match(new RegExp(r));return t?t[t.length>1?t.length-1:0]:null},n.REGEXMATCH=function(n,r,t){if(arguments.length<2)return a;var e=n.match(new RegExp(r));return t?e:!!e},n.REGEXREPLACE=function(n,r,t){return arguments.length<3?a:n.replace(new RegExp(r),t)},n.REPLACE=function(n,r,t,o){return b(r=d(r),t=d(t))||"string"!=typeof n||"string"!=typeof o?e:n.substr(0,r-1)+o+n.substr(r-1+t)},n.REPT=Q,n.RIGHT=function(n,r){var t=I(n,r);return t||(n=E(n),(r=d(r=void 0===r?1:r))instanceof Error?r:n.substring(n.length-r))},n.ROMAN=function(n){if((n=d(n))instanceof Error)return n;for(var r=String(n).split(""),t=["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM","","X","XX","XXX","XL","L","LX","LXX","LXXX","XC","","I","II","III","IV","V","VI","VII","VIII","IX"],e="",o=3;o--;)e=(t[+r.pop()+10*o]||"")+e;return new Array(+r.join("")+1).join("M")+e},n.ROUND=Tr,n.ROUNDDOWN=function(n,r){var t=I(n=d(n),r=d(r));return t||(n>0?1:-1)*Math.floor(Math.abs(n)*Math.pow(10,r))/Math.pow(10,r)},n.ROUNDUP=function(n,r){var t=I(n=d(n),r=d(r));return t||(n>0?1:-1)*Math.ceil(Math.abs(n)*Math.pow(10,r))/Math.pow(10,r)},n.ROW=function(n,r){return 2!==arguments.length?a:r<0?i:n instanceof Array&&"number"==typeof r?0!==n.length?j.row(n,r):void 0:e},n.ROWS=function(n){return 1!==arguments.length?a:n instanceof Array?0===n.length?0:j.rows(n):e},n.RRI=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:0===n||0===r?i:Math.pow(t/r,1/n)-1},n.RSQ=function(n,r){return b(n=M(h(n)),r=M(h(r)))?e:Math.pow(tr(n,r),2)},n.SEARCH=function(n,r,t){var o;return"string"!=typeof n||"string"!=typeof r?e:(t=void 0===t?0:t,0===(o=r.toLowerCase().indexOf(n.toLowerCase(),t-1)+1)?e:o)},n.SEC=function(n){return(n=d(n))instanceof Error?n:1/Math.cos(n)},n.SECH=function(n){return(n=d(n))instanceof Error?n:2/(Math.exp(n)+Math.exp(-n))},n.SECOND=function(n){return(n=N(n))instanceof Error?n:n.getSeconds()},n.SERIESSUM=function(n,r,t,o){if(b(n=d(n),r=d(r),t=d(t),o=M(o)))return e;for(var u=o[0]*Math.pow(n,r),i=1;i<o.length;i++)u+=o[i]*Math.pow(n,r+i*t);return u},n.SHEET=function(){throw new Error("SHEET is not implemented")},n.SHEETS=function(){throw new Error("SHEETS is not implemented")},n.SIGN=function(n){return(n=d(n))instanceof Error?n:n<0?-1:0===n?0:1},n.SIN=function(n){return(n=d(n))instanceof Error?n:Math.sin(n)},n.SINH=function(n){return(n=d(n))instanceof Error?n:(Math.exp(n)-Math.exp(-n))/2},n.SKEW=fr,n.SKEWP=wt,n.SLN=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:0===t?i:(n-r)/t},n.SLOPE=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=j.mean(r),o=j.mean(n),u=r.length,i=0,a=0,f=0;f<u;f++)i+=(r[f]-t)*(n[f]-o),a+=Math.pow(r[f]-t,2);return i/a},n.SMALL=cr,n.SPLIT=function(n,r){return n.split(r)},n.SQRT=function(n){return(n=d(n))instanceof Error?n:n<0?i:Math.sqrt(n)},n.SQRT1_2=function(){return 1/Math.sqrt(2)},n.SQRT2=function(){return Math.sqrt(2)},n.SQRTPI=function(n){return(n=d(n))instanceof Error?n:Math.sqrt(n*Math.PI)},n.STANDARDIZE=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:(n-r)/t},n.STDEV=lr,n.STDEVA=function(){var n=gr.apply(this,arguments),r=Math.sqrt(n);return r},n.STDEVP=It,n.STDEVPA=function(){var n=vr.apply(this,arguments),r=Math.sqrt(n);return isNaN(r)&&(r=i),r},n.STDEVS=yt,n.STEYX=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=j.mean(r),o=j.mean(n),u=r.length,i=0,a=0,f=0,c=0;c<u;c++)i+=Math.pow(n[c]-o,2),a+=(r[c]-t)*(n[c]-o),f+=Math.pow(r[c]-t,2);return Math.sqrt((i-a*a/f)/(u-2))},n.SUBSTITUTE=function(n,r,t,o){if(arguments.length<3)return a;if(n&&r){if(void 0===o)return n.split(r).join(t);if(o=Math.floor(Number(o)),Number.isNaN(o)||o<=0)return e;for(var u=0,i=0;u>-1&&n.indexOf(r,u)>-1;)if(i++,(u=n.indexOf(r,u+1))>-1&&i===o)return n.substring(0,u)+t+n.substring(u+r.length);return n}return n},n.SUBTOTAL=function(n,r){if((n=d(n))instanceof Error)return n;switch(n){case 1:case 101:return xn(r);case 2:case 102:return Fn(r);case 3:case 103:return _n(r);case 4:case 104:return Qn(r);case 5:case 105:return Zn(r);case 6:case 106:return br(r);case 7:case 107:return lr.S(r);case 8:case 108:return lr.P(r);case 9:case 109:return Sr(r);case 10:case 110:return hr.S(r);case 11:case 111:return hr.P(r)}},n.SUM=Sr,n.SUMIF=function(n,r,t){if(n=h(n),t=t?h(t):n,n instanceof Error)return n;if(null==r||r instanceof Error)return 0;for(var e=0,o="*"===r,u=o?null:wn(r+""),i=0;i<n.length;i++){var a=n[i],f=t[i];if(o)e+=a;else{var c=[Mn(a,En)].concat(u);e+=In(c)?f:0}}return e},n.SUMIFS=function(){var n=g(arguments),r=M(h(n.shift()));if(r instanceof Error)return r;for(var t=n,e=t.length/2,o=0;o<e;o++)t[2*o]=h(t[2*o]);for(var u=0,i=0;i<r.length;i++){for(var a=!1,f=0;f<e;f++){var c=t[2*f][i],l=t[2*f+1],s=void 0===l||"*"===l,v=!1;if(s)v=!0;else{var p=wn(l+""),m=[Mn(c,En)].concat(p);v=In(m)}if(!v){a=!1;break}a=!0}a&&(u+=r[i])}return u},n.SUMPRODUCT=function(){if(!arguments||0===arguments.length)return e;for(var n,r,t,o,u=arguments.length+1,i=0,a=0;a<arguments[0].length;a++)if(arguments[0][a]instanceof Array)for(var f=0;f<arguments[0][a].length;f++){for(n=1,r=1;r<u;r++){var c=arguments[r-1][a][f];if(c instanceof Error)return c;if((o=d(c))instanceof Error)return o;n*=o}i+=n}else{for(n=1,r=1;r<u;r++){var l=arguments[r-1][a];if(l instanceof Error)return l;if((t=d(l))instanceof Error)return t;n*=t}i+=n}return i},n.SUMSQ=function(){var n=M(h(arguments));if(n instanceof Error)return n;for(var r=0,t=n.length,e=0;e<t;e++)r+=An(n[e])?n[e]*n[e]:0;return r},n.SUMX2MY2=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;for(var t=0,o=0;o<n.length;o++)t+=n[o]*n[o]-r[o]*r[o];return t},n.SUMX2PY2=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;var t=0;n=M(h(n)),r=M(h(r));for(var o=0;o<n.length;o++)t+=n[o]*n[o]+r[o]*r[o];return t},n.SUMXMY2=function(n,r){if(b(n=M(h(n)),r=M(h(r))))return e;var t=0;n=h(n),r=h(r);for(var o=0;o<n.length;o++)t+=Math.pow(n[o]-r[o],2);return t},n.SWITCH=function(){var n;if(arguments.length>0){var r=arguments[0],t=arguments.length-1,o=Math.floor(t/2),u=!1,i=t%2!=0,f=t%2==0?null:arguments[arguments.length-1];if(o)for(var c=0;c<o;c++)if(r===arguments[2*c+1]){n=arguments[2*c+2],u=!0;break}u||(n=i?f:a)}else n=e;return n},n.SYD=function(n,r,t,o){return b(n=d(n),r=d(r),t=d(t),o=d(o))?e:0===t||o<1||o>t?i:(n-r)*(t-(o=parseInt(o,10))+1)*2/(t*(t+1))},n.T=function(n){return n instanceof Error||"string"==typeof n?n:""},n.TAN=function(n){return(n=d(n))instanceof Error?n:Math.tan(n)},n.TANH=function(n){if((n=d(n))instanceof Error)return n;var r=Math.exp(2*n);return(r-1)/(r+1)},n.TBILLEQ=function(n,r,t){return b(n=N(n),r=N(r),t=d(t))?e:t<=0||n>r||r-n>31536e6?i:365*t/(360-t*q(n,r,!1))},n.TBILLPRICE=function(n,r,t){return b(n=N(n),r=N(r),t=d(t))?e:t<=0||n>r||r-n>31536e6?i:100*(1-t*q(n,r,!1)/360)},n.TBILLYIELD=function(n,r,t){return b(n=N(n),r=N(r),t=d(t))?e:t<=0||n>r||r-n>31536e6?i:360*(100-t)/(t*q(n,r,!1))},n.TDIST=bt,n.TDISTRT=Tt,n.TEXT=function(){throw new Error("TEXT is not implemented")},n.TEXTJOIN=function(n,r){for(var t,e=arguments.length,o=new Array(e>2?e-2:0),u=2;u<e;u++)o[u-2]=arguments[u];if("boolean"!=typeof r&&(r=m(r)),arguments.length<3)return a;n=null!==(t=n)&&void 0!==t?t:"";var i=h(o),f=r?i.filter((function(n){return n})):i;if(Array.isArray(n)){n=h(n);for(var c=f.map((function(n){return[n]})),l=0,s=0;s<c.length-1;s++)c[s].push(n[l]),++l===n.length&&(l=0);return(f=h(c)).join("")}return f.join(n)},n.TIME=function(n,r,t){return b(n=d(n),r=d(r),t=d(t))?e:n<0||r<0||t<0?i:(3600*n+60*r+t)/86400},n.TIMEVALUE=function(n){return(n=N(n))instanceof Error?n:(3600*n.getHours()+60*n.getMinutes()+n.getSeconds())/86400},n.TINV=St,n.TODAY=function(){return P(new Date)},n.TRANSPOSE=function(n){return n?j.transpose(n):a},n.TREND=function(n,r,t){if(b(n=M(h(n)),r=M(h(r)),t=M(h(t))))return e;var o=Kn(n,r),u=o[0],i=o[1],a=[];return t.forEach((function(n){a.push(u*n+i)})),a},n.TRIM=function(n){return(n=E(n))instanceof Error?n:n.replace(/\s+/g," ").trim()},n.TRIMMEAN=function(n,r){if(b(n=M(h(n)),r=d(r)))return e;var t,o,u=wr(n.length*r,2)/2;return j.mean((t=A(n.sort((function(n,r){return n-r})),u),o=(o=u)||1,t&&"function"==typeof t.slice?t.slice(0,t.length-o):t))},n.TRUE=function(){return!0},n.TRUNC=function(n,r){var t=I(n=d(n),r=d(r));return t||(n>0?1:-1)*Math.floor(Math.abs(n)*Math.pow(10,r))/Math.pow(10,r)},n.TTEST=At,n.TYPE=function(n){return An(n)?1:Dn(n)?2:Sn(n)?4:Tn(n)?16:Array.isArray(n)?64:void 0},n.UNICHAR=$,n.UNICODE=Z,n.UNIQUE=Rn,n.UPPER=function(n){return(n=E(n))instanceof Error?n:n.toUpperCase()},n.VALUE=function(n){var r=I(n);if(r)return r;if("string"!=typeof n)return e;var t=/(%)$/.test(n)||/^(%)/.test(n);if(""===(n=(n=(n=n.replace(/^[^0-9-]{0,3}/,"")).replace(/[^0-9]{0,3}$/,"")).replace(/[ ,]/g,"")))return e;var o=Number(n);return isNaN(o)?e:(o=o||0,t&&(o*=.01),o)},n.VAR=hr,n.VARA=gr,n.VARP=Dt,n.VARPA=vr,n.VARS=Rt,n.VDB=function(){throw new Error("VDB is not implemented")},n.VLOOKUP=Xt,n.WEEKDAY=function(n,r){if((n=N(n))instanceof Error)return n;void 0===r&&(r=1);var t=n.getDay();return x[r][t]},n.WEEKNUM=function(n,r){if((n=N(n))instanceof Error)return n;if(void 0===r&&(r=1),21===r)return U(n);var t=C[r],e=new Date(n.getFullYear(),0,1),o=e.getDay()<t?1:0;return e-=24*Math.abs(e.getDay()-t)*60*60*1e3,Math.floor((n-e)/864e5/7+1)+o},n.WEIBULL=pr,n.WEIBULLDIST=Ct,n.WORKDAY=_,n.WORKDAYINTL=xt,n.XIRR=function(n,r,t){if(b(n=M(h(n)),r=w(h(r)),t=d(t)))return e;for(var o=function(n,r,t){for(var e=t+1,o=n[0],u=1;u<n.length;u++)o+=n[u]/Math.pow(e,L(r[u],r[0])/365);return o},u=function(n,r,t){for(var e=t+1,o=0,u=1;u<n.length;u++){var i=L(r[u],r[0])/365;o-=i*n[u]/Math.pow(e,i+1)}return o},a=!1,f=!1,c=0;c<n.length;c++)n[c]>0&&(a=!0),n[c]<0&&(f=!0);if(!a||!f)return i;var l,s,g,v=t=t||.1,p=!0;do{l=v-(g=o(n,r,v))/u(n,r,v),s=Math.abs(l-v),v=l,p=s>1e-10&&Math.abs(g)>1e-10}while(p);return v},n.XNPV=function(n,r,t){if(b(n=d(n),r=M(h(r)),t=w(h(t))))return e;for(var o=0,u=0;u<r.length;u++)o+=r[u]/Math.pow(1+n,L(t[u],t[0])/365);return o},n.XOR=function(){for(var n=h(arguments),r=e,t=0;t<n.length;t++){if(n[t]instanceof Error)return n[t];void 0!==n[t]&&null!==n[t]&&"string"!=typeof n[t]&&(r===e&&(r=0),n[t]&&r++)}return r===e?r:!!(1&Math.floor(Math.abs(r)))},n.YEAR=function(n){return(n=N(n))instanceof Error?n:n.getFullYear()},n.YEARFRAC=k,n.YIELD=function(){throw new Error("YIELD is not implemented")},n.YIELDDISC=function(){throw new Error("YIELDDISC is not implemented")},n.YIELDMAT=function(){throw new Error("YIELDMAT is not implemented")},n.Z=mr,n.ZTEST=Ot,Object.defineProperty(n,"__esModule",{value:!0})}));
//# sourceMappingURL=formula.min.js.map
// dr_codemirror.js.coffee
(function() {
  var codeMirrorContent, initCodeMirror;

  decko.editors.add(".codemirror-editor-textarea", function() {
    return initCodeMirror($(this));
  }, function() {
    return codeMirrorContent($(this));
  });

  initCodeMirror = function(textarea) {
    var cm;
    cm = CodeMirror.fromTextArea(textarea[0], {
      mode: "coffeescript",
      theme: "midnight"
    });
    textarea.data("codeMirror", cm);
    return setTimeout((function() {
      return cm.refresh();
    }), 200);
  };

  codeMirrorContent = function(textarea) {
    return textarea.data("codeMirror").getValue();
  };

}).call(this);

// tree.js.coffee
(function() {
  var expandNextStubs, readyToExpand;

  $(function() {
    return $("body").on("shown.bs.collapse", ".tree-collapse", function(event) {
      return expandNextStubs($(event.target));
    });
  });

  decko.slot.ready(function(slot) {});

  expandNextStubs = function(container) {
    return container.find(".card-slot-stub").each(function() {
      var s;
      s = $(this);
      if (!readyToExpand(s)) {
        return;
      }
      s.slotReload(s.data("stubUrl"));
      return s.removeClass("card-slot-stub");
    });
  };

  readyToExpand = function(stub) {
    var item;
    item = stub.closest(".tree-item");
    return item.children(".tree-header").is(":visible") || item.parent().hasClass("_tree-top");
  };

}).call(this);
