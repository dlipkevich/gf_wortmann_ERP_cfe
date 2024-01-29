﻿#Область СлужебныеПроцедурыИФункции

&НаСервере
&Вместо("СоздатьДокументыПоЗакрытойПоставке")
Процедура гф_СоздатьДокументыПоЗакрытойПоставке(ДокПТУ, ТекстСообщения)
	Запрос = Новый Запрос;
	
	#Область Перемещение_товаров
	НужноСоздаватьПеремещение = Ложь;
	Запрос.Текст = "
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ПеремещениеТоваров.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.ПеремещениеТоваров КАК ПеремещениеТоваров
	|ГДЕ
	|	ПеремещениеТоваров.ДокументОснование = &ДокументОснование
	|	И НЕ ПеремещениеТоваров.ПометкаУдаления";
	Запрос.УстановитьПараметр("ДокументОснование", ДокПТУ);
	Результат = Запрос.Выполнить();
	Если Не Результат.Пустой() Тогда
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ОбщегоНазначения.СообщитьПользователю("Уже существует документ " + Выборка["Ссылка"] + "
		|по документу-основанию " + ДокПТУ);
	Иначе	
		НужноСоздаватьПеремещение = Истина;
	КонецЕсли;
	Если Не НужноСоздаватьПеремещение Тогда
		обПеремещение = Выборка["Ссылка"].ПолучитьОбъект();
	Иначе
		обПеремещение = Документы.ПеремещениеТоваров.СоздатьДокумент();
		Склад = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДокПТУ, "Склад");
		УпЛисты = ДокПТУ.гф_ПродукцияВКоробах.Выгрузить();
		ДанныеЗаполнения = Новый Структура("Основание, Склад", ДокПТУ, Склад);
		обПеремещение.Дата = ТекущаяДатаСеанса();
		обПеремещение.Заполнить(ДанныеЗаполнения);
		// #wortmann { 
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee09fd8c109687
		// Галфинд Sakovich 2023/06/15
		ТаблицаТоваровДляИзменения = ПолучитьИзменениеСоставаТоваровИзПересортицы(УпЛисты.ВыгрузитьКолонку("IDКороба")); 
		Если ТаблицаТоваровДляИзменения <> Неопределено Тогда
		    ПереопределитьСоставТоваровСУчетомПересортицы(обПеремещение, ТаблицаТоваровДляИзменения);
		КонецЕсли;
		// } #wortmann

		мСклады = _омОбщегоНазначенияКлиентСервер.ПолучитьГлобальноеЗначениеМассив("гф_ГлобальныеЗначенияОсновнойСклад");
		Запрос.Текст = "
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	Склады.Ссылка КАК Склад
		|ИЗ
		|	Справочник.Склады КАК Склады
		|ГДЕ
		|	Склады.Ссылка В(&мСклады)
		|	И Склады.гф_Организация = &Организация";
		Запрос.УстановитьПараметр("мСклады", мСклады);	
		Запрос.УстановитьПараметр("Организация", обПеремещение.Организация);
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		обПеремещение.СкладПолучатель = Выборка["Склад"];
		// #wortmann {
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811edf49fcd05bbaf
		// Первоначальный статус у документа Перемещения должен быть "Отгружено"
		// Галфинд ДомнышеваКР 2023/05/23
		//обПеремещение.Статус = перечисления.СтатусыПеремещенийТоваров.Принято;
		обПеремещение.Статус = перечисления.СтатусыПеремещенийТоваров.Отгружено;
		// } #wortmann
		Запрос.Текст = "
		|ВЫБРАТЬ
		|	т.IDКороба КАК УпаковочныйЛист
		|ПОМЕСТИТЬ втУЛ
		|ИЗ
		|	&УпЛисты КАК т
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	докУпаковочныйЛист.Ссылка КАК УпаковочныйЛист,
		|	спрНоменклатура.Артикул КАК Артикул,
		|	докУпаковочныйЛист.Код КАК IDКороба,
		|	докУпаковочныйЛист.ВсегоМест КАК КоличествоПар
		|ИЗ
		|	втУЛ КАК вт
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист КАК докУпаковочныйЛист
		|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыКомплектацииНоменклатуры КАК спрВариантыКомплектацииНоменклатуры
		|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК спрНоменклатура
		|				ПО (спрВариантыКомплектацииНоменклатуры.Владелец = спрНоменклатура.Ссылка)
		|			ПО (докУпаковочныйЛист.гф_Комплектация = спрВариантыКомплектацииНоменклатуры.Ссылка)
		|		ПО (вт.УпаковочныйЛист = докУпаковочныйЛист.Ссылка)";
		Запрос.УстановитьПараметр("УпЛисты", УпЛисты);
		Результат = Запрос.Выполнить();
		обПеремещение.гф_ТоварыВКоробах.Загрузить(Результат.Выгрузить());
		Попытка
			обПеремещение.Записать(РежимЗаписиДокумента.Проведение);
			ОбщегоНазначения.СообщитьПользователю("Записан документ " + обПеремещение.Ссылка);
		Исключение
			ОбщегоНазначения.СообщитьПользователю("Не удалось создать документ ""Перемещение товаров"" " + 
			"на основании документа " + ДокПТУ);
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
			Возврат;
		КонецПопытки;
	КонецЕсли;
	
	#КонецОбласти
	
	НужноСоздаватьРасходныйОрдер = Ложь;
	НужноСоздаватьПриходныйОрдер = Ложь;
	
	Ссылка = обПеремещение["Ссылка"];
	Статус = обПеремещение["Статус"];
	СкладОтправитель = обПеремещение["СкладОтправитель"];
	СкладПолучатель = обПеремещение["СкладПолучатель"];
	
	СкладОтправительОрдерный = обПеремещение.ОпределитьОрдерныйЛиСклад(СкладОтправитель);
	СкладПолучательОрдерный  = обПеремещение.ОпределитьОрдерныйЛиСклад(СкладПолучатель);
	СкладПолучательКоробочный = УправлениеСвойствами.ЗначениеСвойства(СкладПолучатель, "гф_СкладыТоварыВКоробах") = Истина;
	СкладОтправительКоробочный = УправлениеСвойствами.ЗначениеСвойства(СкладОтправитель, "гф_СкладыТоварыВКоробах") = Истина;
	ТехническоеНазначение = Справочники.Назначения.гф_Техническое;  //Добавлено  Галфинд \ Sakovich 29.01.2024

	ЗапросТекст = "ВЫБРАТЬ
	|	регТКП.Номенклатура КАК Номенклатура,
	|	регТКП.Характеристика КАК Характеристика,
	// vvv Галфинд \ Sakovich 29.01.2024
	//|	регТКП.Назначение КАК Назначение,
	|	&Назначение КАК Назначение,
	// ^^^ Галфинд \ Sakovich 29.01.2024
	|	регТКП.Склад КАК Склад,
	|	регТКП.Отправитель КАК Отправитель,
	|	регТКП.ХозяйственнаяОперация КАК ХозяйственнаяОперация,
	|	регТКП.КОформлениюОрдеровПриход КАК КоличествоРОТ,
	|	регТКП.КОформлениюПоступленийПоОрдерамРасход КАК КоличествоПОТ,
	|	ВЫБОР
	|		КОГДА регТКП.КОформлениюОрдеровПриход <> 0
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК РОТ,
	|	ВЫБОР
	|		КОГДА регТКП.КОформлениюПоступленийПоОрдерамРасход <> 0
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ПОТ,
	|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
	|	регТКП.Номенклатура.ЕдиницаИзмерения КАК Упаковка,
	|	&Перемещение КАК ДокументОтгрузки,
	|	&Перемещение КАК Распоряжение
	|ПОМЕСТИТЬ Обороты
	|ИЗ
	|	РегистрНакопления.ТоварыКПоступлению.Обороты(, , , ДокументПоступления = &Перемещение) КАК регТКП
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|		ПО регТКП.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
	|			И регТКП.Характеристика = ШтрихкодыНоменклатуры.Характеристика
	|			И регТКП.Номенклатура.ЕдиницаИзмерения = ШтрихкодыНоменклатуры.Упаковка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(СУММА(Обороты.КоличествоРОТ), 0) КАК КоличествоРОТ,
	|	ЕСТЬNULL(СУММА(Обороты.КоличествоПОТ), 0) КАК КоличествоПОТ
	|ИЗ
	|	Обороты КАК Обороты";
	Запрос.Текст = ЗапросТекст;
	Запрос.УстановитьПараметр("Назначение", ТехническоеНазначение);  //Добавлено  Галфинд \ Sakovich 29.01.2024
	Запрос.УстановитьПараметр("Перемещение", Ссылка);
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	ОборотыИтоги = ПакетРезультатов[1];
	ВыборкаИтоги = ОборотыИтоги.Выбрать();
	ВыборкаИтоги.Следующий();
	ЕстьТоварыДляРОТ = ВыборкаИтоги["КоличествоРОТ"] <> 0;
	ЕстьТоварыДляПОТ = ВыборкаИтоги["КоличествоПОТ"] <> 0;
	
	Если СкладОтправительОрдерный Тогда
		УжеЕстьРасходныйОрдер = обПеремещение.ПроверитьНаличиеОрдераПоОснованию("РасходныйОрдерНаТовары");
		Если Не УжеЕстьРасходныйОрдер 
			И ЕстьТоварыДляРОТ Тогда
			НужноСоздаватьРасходныйОрдер = Истина;	
		КонецЕсли;
	КонецЕсли;
	
	Если СкладПолучательОрдерный Тогда
		УжеЕстьПриходныйОрдер = обПеремещение.ПроверитьНаличиеОрдераПоОснованию("ПриходныйОрдерНаТовары");
		Если Не УжеЕстьПриходныйОрдер
			И ЕстьТоварыДляПОТ Тогда
			НужноСоздаватьПриходныйОрдер = Истина;	
		КонецЕсли;
	КонецЕсли;
	
	#Область Приходный_ордер_на_товары
	Если НужноСоздаватьПриходныйОрдер Тогда
		СтруктураПолейЗаполнения = Новый Структура();
		СтруктураПолейЗаполнения.Вставить("Склад", "СкладПолучатель");
		СтруктураПолейЗаполнения.Вставить("Распоряжение", "Ссылка");
		СтруктураПолейЗаполнения.Вставить("ДатаПоступления");
		СтруктураПолейЗаполнения.Вставить("Отправитель", "СкладОтправитель");
		СтруктураПолейЗаполнения.Вставить("ДатаВходящегоДокумента", "Дата");
		СтруктураПолейЗаполнения.Вставить("НомерВходящегоДокумента", "Номер");
		СтруктураПолейЗаполнения.Вставить("ХозяйственнаяОперация");
		
		СтруктРеквизитов = Новый ФиксированнаяСтруктура(СтруктураПолейЗаполнения);
		ЗначенияРеквизитовОснования = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, СтруктРеквизитов);
		
		ДанныеЗаполнения = Новый Структура(
		"Склад, Помещение, Распоряжение, ДатаПоступления, ЗонаПриемки, СкладскаяОперация, " + 
		"Отправитель, ДатаВходящегоДокумента, НомерВходящегоДокумента, ХозяйственнаяОперация");
		ЗаполнитьЗначенияСвойств(ДанныеЗаполнения, ЗначенияРеквизитовОснования);
		ДанныеЗаполнения["СкладскаяОперация"] = Перечисления.СкладскиеОперации.ПриемкаПоПеремещению;
		
		обПрОрдер = Документы.ПриходныйОрдерНаТовары.СоздатьДокумент();
		обПрОрдер["Дата"] = ТекущаяДатаСеанса();
		обПрОрдер.Заполнить(ДанныеЗаполнения);
		обПрОрдер["Ответственный"] = Пользователи.АвторизованныйПользователь();
		обПрОрдер["Статус"] = Перечисления.СтатусыПриходныхОрдеров.КПоступлению;
		
		Если СкладПолучательКоробочный Тогда
			ТоварыКПоступлению = гф_ПеремещениеСервер.ДанныеЗаполненияПриходныйОрдерНаТовары(Ссылка, Истина, ТехническоеНазначение);
			ВыборкаУЛ = ТоварыКПоступлению.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			обПрОрдер.Товары.Очистить();
			Пока ВыборкаУЛ.Следующий() Цикл
				нсУЛ = обПрОрдер.Товары.Добавить();
				нсУЛ["Количество"] = 1;
				нсУЛ["КоличествоУпаковок"] = 1;
				нсУЛ["УпаковочныйЛист"] = ВыборкаУЛ["УпаковочныйЛистРодитель"];
				нсУЛ["ЭтоУпаковочныйЛист"] = Истина;
				ВыборкаТоварыУЛ = ВыборкаУЛ.Выбрать();
				Пока ВыборкаТоварыУЛ.Следующий() Цикл
					нсТовар = обПрОрдер.Товары.Добавить();
					ЗаполнитьЗначенияСвойств(нсТовар, ВыборкаТоварыУл);
				КонецЦикла;
			КонецЦикла;
			обПрОрдер.ВсегоМест = УпаковочныеЛистыСервер.КоличествоМестВТЧ(обПрОрдер.Товары);
		Иначе	
			ТоварыКПоступлению = гф_ПеремещениеСервер.ДанныеЗаполненияПриходныйОрдерНаТовары(Ссылка, Ложь, ТехническоеНазначение);
			обПрОрдер.Товары.Загрузить(ТоварыКПоступлению);
			обПрОрдер["РежимПросмотраПоТоварам"] = 1;
			обПрОрдер.ВсегоМест = обПрОрдер.Товары.Итог("КоличествоУпаковок");
		КонецЕсли;
		
		Распоряжение = обПрОрдер.Распоряжение;
		ЗаполнятьШКПриходногоОрдера = Истина;
		Если СкладОтправительКоробочный И СкладПолучательКоробочный Тогда
			// заполняем Агрегатами кодов маркировки
			лТовары = обПрОрдер.Товары.Выгрузить();
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	т.УпаковочныйЛист КАК УпаковочныйЛист,
			|	т.ЭтоУпаковочныйЛист
			|ПОМЕСТИТЬ УпЛисты
			|ИЗ
			|	&Товары КАК т
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
			|ИЗ
			|	УпЛисты КАК УпЛисты
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
			|		ПО УпЛисты.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
			|ГДЕ
			|	УпЛисты.ЭтоУпаковочныйЛист
			|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL 
			|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("Товары", лТовары);
			
		ИначеЕсли  СкладОтправительКоробочный И Не СкладПолучательКоробочный Тогда
			// заполняем Кодами маркировки
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
			|ИЗ
			|	Документ.ПеремещениеТоваров.гф_ТоварыВКоробах КАК ПеремещениеТоваровгф_ТоварыВКоробах
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
			|		ПО ПеремещениеТоваровгф_ТоварыВКоробах.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода
			|ГДЕ
			|	ПеремещениеТоваровгф_ТоварыВКоробах.Ссылка = &Распоряжение";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
		Иначе
			ЗаполнятьШКПриходногоОрдера = Ложь;
		КонецЕсли;
		
		Если ЗаполнятьШКПриходногоОрдера Тогда
			Результат = Запрос.Выполнить();
			Если Не Результат.Пустой() Тогда
				тзШтрихкоды = Результат.Выгрузить();
				обПрОрдер.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
			КонецЕсли;
		КонецЕсли;
		
		Попытка
			обПрОрдер.Записать(РежимЗаписиДокумента.Проведение);
			ОбщегоНазначения.СообщитьПользователю("Записан документ " + обПрОрдер.Ссылка);
		Исключение
			ОбщегоНазначения.СообщитьПользователю("Не удалось записать документ ""Приходный ордер на товары""");
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
	#КонецОбласти
	
	#Область Расходный_ордер_на_товары
	
	Если НужноСоздаватьРасходныйОрдер Тогда
		ДатаОрдера = ТекущаяДатаСеанса();
		СтруктураЗаполнения = Новый Структура();
		СтруктураЗаполнения.Вставить("Склад", СкладОтправитель);
		СтруктураЗаполнения.Вставить("Получатель", СкладПолучатель);
		СтруктураЗаполнения.Вставить("ДатаОтгрузки", ДатаОрдера);
		СтруктураЗаполнения.Вставить("Дата", ДатаОрдера);
		СтруктураЗаполнения.Вставить("СкладскаяОперация", Перечисления.СкладскиеОперации.ОтгрузкаПоПеремещению);
		СтруктураЗаполнения.Вставить("РежимПросмотраПоТоварам", 1);
		
		обРасхОрдер = Документы.РасходныйОрдерНаТовары.СоздатьДокумент();
		ЗаполнитьЗначенияСвойств(обРасхОрдер, СтруктураЗаполнения);
		
		ТоварыКОтгрузке = ПакетРезультатов[0].Выгрузить();
		мСтрок = ТоварыКОтгрузке.НайтиСтроки(Новый Структура("РОТ", Истина));
		Для каждого эл Из мСтрок Цикл
			нс = обРасхОрдер.ТоварыПоРаспоряжениям.Добавить();
			ЗаполнитьЗначенияСвойств(нс, эл);
			нс["Количество"] =эл["КоличествоПОТ"];
		КонецЦикла;
		ДанныеЗаполнения = Новый Структура();
		обРасхОрдер.Заполнить(ДанныеЗаполнения);
		
		Если СкладОтправительКоробочный Тогда
			ОтгружаемыеТовары = гф_ПеремещениеСервер.ДанныеЗаполненияРасходныОрдерйНаТовары( 
			Ссылка, 
			Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отобрать, 
			Истина,
			ТехническоеНазначение);
			ВыборкаУЛ = ОтгружаемыеТовары.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			обРасхОрдер.ОтгружаемыеТовары.Очистить();
			Пока ВыборкаУЛ.Следующий() Цикл
				нсУЛ = обРасхОрдер.ОтгружаемыеТовары.Добавить();
				нсУЛ["Количество"] = 1;
				нсУЛ["КоличествоУпаковок"] = 1;
				нсУЛ["УпаковочныйЛист"] = ВыборкаУЛ["УпаковочныйЛистРодитель"];
				нсУЛ["ЭтоУпаковочныйЛист"] = Истина;
				ВыборкаТоварыУЛ = ВыборкаУЛ.Выбрать();
				Пока ВыборкаТоварыУЛ.Следующий() Цикл
					нсТовар = обРасхОрдер.ОтгружаемыеТовары.Добавить();
					ЗаполнитьЗначенияСвойств(нсТовар, ВыборкаТоварыУл);
				КонецЦикла;
			КонецЦикла;		
			обРасхОрдер.ВсегоМест = УпаковочныеЛистыСервер.КоличествоМестВТЧ(обРасхОрдер.ОтгружаемыеТовары);
		Иначе
			ОтгружаемыеТовары = гф_ПеремещениеСервер.ДанныеЗаполненияРасходныОрдерйНаТовары( 
			Ссылка, 
			Перечисления.ДействияСоСтрокамиОрдеровНаОтгрузку.Отобрать, 
			Ложь,
			ТехническоеНазначение);
			обРасхОрдер.ОтгружаемыеТовары.Загрузить(ОтгружаемыеТовары);
			обРасхОрдер.ВсегоМест = обРасхОрдер.ОтгружаемыеТовары.Итог("КоличествоУпаковок");
		КонецЕсли;
		
		// пересчет товаров по распоряжениям по отгруженным товарам
		тзОтгружаемыеТоварыПолная = обРасхОрдер.ОтгружаемыеТовары.Выгрузить();
		мСтрокТовары = тзОтгружаемыеТоварыПолная.НайтиСтроки(Новый Структура("ЭтоУпаковочныйЛист", Ложь));
		тзОтгружаемыеТовары = тзОтгружаемыеТоварыПолная.Скопировать(мСтрокТовары);
		тзОтгружаемыеТовары.Свернуть("Номенклатура, Характеристика, Назначение", "Количество");
		тзотгружаемыеТовары.Колонки.Добавить("Распоряжение");
		тзОтгружаемыеТовары.ЗаполнитьЗначения(Ссылка, "Распоряжение");
		обРасхОрдер.ТоварыПоРаспоряжениям.Загрузить(тзОтгружаемыеТовары);
		
		Если СкладОтправительКоробочный Тогда
			// заполняем Агрегатами кодов маркировки
			лТовары = обРасхОрдер.ОтгружаемыеТовары.Выгрузить();
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	т.УпаковочныйЛист КАК УпаковочныйЛист,
			|	т.ЭтоУпаковочныйЛист
			|ПОМЕСТИТЬ УпЛисты
			|ИЗ
			|	&Товары КАК т
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
			|ИЗ
			|	УпЛисты КАК УпЛисты
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
			|		ПО УпЛисты.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода
			|ГДЕ
			|	УпЛисты.ЭтоУпаковочныйЛист
			|	И ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL 
			|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("Товары", лТовары);
		Иначе
			// заполняем Кодами маркировки
			ТекстЗапроса = "ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК ШтрихкодУпаковки
			|ИЗ
			|	Документ.ПеремещениеТоваров.гф_ТоварыВКоробах КАК ПеремещениеТоваровгф_ТоварыВКоробах
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
			|		ПО ПеремещениеТоваровгф_ТоварыВКоробах.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода
			|ГДЕ
			|	ПеремещениеТоваровгф_ТоварыВКоробах.Ссылка = &ДокПеремещение";
			Запрос.Текст = ТекстЗапроса;
			Запрос.УстановитьПараметр("ДокПеремещение", Ссылка);
		КонецЕсли;
		
		Результат = Запрос.Выполнить();
		Если Не Результат.Пустой() Тогда
			тзШтрихкоды = Результат.Выгрузить();
			обРасхОрдер.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
		КонецЕсли;
		
		обРасхОрдер.Статус = Перечисления.СтатусыРасходныхОрдеров.Подготовлено;
		
		Попытка
			обРасхОрдер.Записать(РежимЗаписиДокумента.Проведение);
			ОбщегоНазначения.СообщитьПользователю("Записан документ " + обРасхОрдер.Ссылка);
		Исключение
			ОбщегоНазначения.СообщитьПользователю("Не удалось провести документ в статусе ""Подготовлено"" " + обРасхОрдер.Ссылка);
			ОбщегоНазначения.СообщитьПользователю(ОписаниеОшибки());
			ПроводитьРасхОрдер = Ложь;
		КонецПопытки;
		
	КонецЕсли;
	
	#КонецОбласти
	
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811edf49fcd05bbaf
	// Требуется смена статуса и перепроведение ПриходногоОрдера по Таможенному складу
	// Галфинд ДомнышеваКР 2023/05/23 
	ПроверитьИПерезаписатьСтатусПриходного(ДокПТУ);
	// } #wortmann

КонецПроцедуры

#КонецОбласти
