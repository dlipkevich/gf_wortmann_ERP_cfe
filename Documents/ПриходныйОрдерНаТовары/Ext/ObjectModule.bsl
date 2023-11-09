﻿#Если НЕ МобильныйАвтономныйСервер Тогда
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

// #wortmann {
// #3.3.19 ТЗ_Приходный ордер_v2.docx
// группировка номенклатуры по Упаковочным листам,
// если они присутствуют в распоряжении.
// Галфинд Sakovich 2022/08/25
&После("ЗаполнитьТоварыПоТоварамКПоступлению")
Процедура гф_ЗаполнитьТоварыПоТоварамКПоступлению(ВидЗаполнения, ДатаПоступления)
	
	НужноЗаполнять = (ВидЗаполнения = "Номенклатура"
	Или ВидЗаполнения = "НоменклатураКоличество") 
	И ЗначениеЗаполнено(Распоряжение) 
	И (ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг")
	Или ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров")
	Или ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПроизводствоБезЗаказа"));
	
	Если Не НужноЗаполнять Тогда
		Возврат;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг") Тогда
		ТекстЗапроса = "ВЫБРАТЬ
		// ++ Галфинд_ДомнышеваКР_31_05_2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811edfeb577c6c1d3
		// УЛ подбирались все, а должны только те что есть в ТЧ у ПТУ
		|	ПТиУ.IDКороба КАК УпЛист
		|ПОМЕСТИТЬ УпакЛисты
		|ИЗ
		|	Документ.ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах КАК ПТиУ
		//|	ПТиУ.Ссылка КАК ПТиУ,
		//|	УпаковочныйЛист.Ссылка КАК УпЛист
		//|ПОМЕСТИТЬ УпакЛисты
		//|ИЗ
		//|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
		//|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ПриобретениеТоваровУслуг КАК ПТиУ
		//|		ПО (УпаковочныйЛист.гф_Поставка = ПТиУ.Ссылка) 
		//  -- Галфинд_ДомнышеваКР_31_05_2023
		|ГДЕ
		|	ПТиУ.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	УпакЛисты.УпЛист КАК УпЛист,
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК КоличествоУпаковок,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК Количество
		|ИЗ
		|	УпакЛисты КАК УпакЛисты
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|		ПО УпакЛисты.УпЛист = УпаковочныйЛистТовары.Ссылка
		|ИТОГИ ПО
		|	УпЛист";
	КонецЕсли;
	
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПроизводствоБезЗаказа") Тогда
		ТекстЗапроса = "ВЫБРАТЬ
		|	ПроизводствоБезЗаказагф_ПродукцияВКоробах.IDКороба КАК УпЛист,
		|	ПроизводствоБезЗаказагф_ПродукцияВКоробах.КоличествоКоробов КАК КоличествоКоробов,
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		|	ЗНАЧЕНИЕ(Справочник.Назначения.гф_Техническое) КАК Назначение,
		|	УпаковочныйЛистТовары.Упаковка КАК Упаковка,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК КоличествоУпаковок,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК Количество
		|ИЗ
		|	Документ.ПроизводствоБезЗаказа.гф_ПродукцияВКоробах КАК ПроизводствоБезЗаказагф_ПродукцияВКоробах
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|		ПО ПроизводствоБезЗаказагф_ПродукцияВКоробах.IDКороба = УпаковочныйЛистТовары.Ссылка
		|ГДЕ
		|	ПроизводствоБезЗаказагф_ПродукцияВКоробах.Ссылка = &Ссылка
		|	И НЕ УпаковочныйЛистТовары.ЭтоУпаковочныйЛист
		|	И УпаковочныйЛистТовары.Номенклатура ЕСТЬ НЕ NULL 
		|ИТОГИ
		|	МАКСИМУМ(КоличествоКоробов)
		|ПО
		|	УпЛист";
	КонецЕсли;
	
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		ТекстЗапроса = " ВЫБРАТЬ
		|	Перемещение.УпаковочныйЛист КАК УпЛист,
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК КоличествоУпаковок,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК Количество
		|ИЗ
		|	Документ.ПеремещениеТоваров.гф_ТоварыВКоробах КАК Перемещение
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|		ПО (Перемещение.УпаковочныйЛист = УпаковочныйЛистТовары.Ссылка)
		|ГДЕ
		|	Перемещение.Ссылка = &Ссылка
		|ИТОГИ ПО
		|	УпЛист";
	КонецЕсли;
	
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Ссылка", Распоряжение);
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Товары.Очистить();
	
	ВыборкаУпЛист = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаУпЛист.Следующий() Цикл
		стрУпЛист = Товары.Добавить();
		стрУпЛист.УпаковочныйЛист = ВыборкаУпЛист.УпЛист;
		стрУпЛист.ЭтоУпаковочныйЛист = Истина;
		стрУпЛист.КоличествоУпаковок = 1;
		стрУпЛист.Количество = 1;
		
		ВыборкаДетали = ВыборкаУпЛист.Выбрать();
		Пока ВыборкаДетали.Следующий() Цикл
			стрТовары = Товары.Добавить();
			ЗаполнитьЗначенияСвойств(стрТовары, ВыборкаДетали );
			стрТовары.УпаковочныйЛистРодитель = ВыборкаУпЛист.УпЛист;
			стрТовары.ЭтоУпаковочныйЛист = Ложь;
			стрТовары.гф_IDКороба = ВыборкаУпЛист.УпЛист;// ++ Галфинд_ДомнышеваКР_31_05_2023
		КонецЦикла;
	КонецЦикла;
	
	ВсегоМест = УпаковочныеЛистыСервер.КоличествоМестВТЧ(Товары);
	
КонецПроцедуры // } #wortmann

// #wortmann {
// #Монитор логиста
// Запись истории статусов ордеров
// Галфинд Окунев 2022/09/13
&После("ПриЗаписи")
Процедура гф_ПриЗаписи(Отказ)
	
	Если Отказ Тогда
		
		Возврат;
		
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	гф_ИсторияСтатусовПриходныхОрдеровСрезПоследних.Статус КАК Статус
	|ИЗ
	|	РегистрСведений.гф_ИсторияСтатусовПриходныхОрдеров.СрезПоследних(, Объект = &Ссылка) КАК гф_ИсторияСтатусовПриходныхОрдеровСрезПоследних
	|ГДЕ
	|	гф_ИсторияСтатусовПриходныхОрдеровСрезПоследних.Статус = &Статус";
	
	Запрос.Параметры.Вставить("Ссылка", Ссылка);
	Запрос.Параметры.Вставить("Статус", Статус);
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда 
		
		Запись = РегистрыСведений.гф_ИсторияСтатусовПриходныхОрдеров.СоздатьМенеджерЗаписи();
		
		Запись.Период			= ТекущаяДатаСеанса();
		Запись.Активность		= Истина;
		Запись.Объект			= Ссылка;
		Запись.Статус			= Статус;    
		Запись.СтатусИзменил	= Пользователи.ТекущийПользователь();
		
		Запись.Записать();
		
	КонецЕсли;	
	
КонецПроцедуры // } #wortmann

// #wortmann {
// Заполнение тч Товары из распоряжений на перемещение
// Галфинд Sakovich 2022/11/02
&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		гф_ЗаполнитьТовары();	
	КонецЕсли;
	
КонецПроцедуры // } #wortmann

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура гф_ЗаполнитьТовары()
	
	Если ТипЗнч(Распоряжение) = Тип("ДокументСсылка.ПеремещениеТоваров") Тогда
		ЗаполнитьТоварыПоПеремещению();	
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьТоварыПоПеремещению()
	
	//++ Галфинд_Домнышева_09_11_2023
	// Необходимо не перезаполнять ТЧ для Виртуального отправителя
	СкладВиртуальный = ПроверкаСкладаНаВиртуальность(Отправитель);
	
	Если СкладВиртуальный Тогда
		Возврат;
	КонецЕсли;
	//-- Галфинд_Домнышева_09_11_2023
	
	ЭтоКоробочныйСклад = УправлениеСвойствами.ЗначениеСвойства(Склад, "гф_СкладыТоварыВКоробах") = Истина;
	Если ЭтоКоробочныйСклад Тогда
		ЗаполнитьТоварыПоТоварамВКоробахПеремещения();
	Иначе
		ЗаполнитьТоварыПоТоварамПеремещения();
	КонецЕсли;

КонецПроцедуры

Процедура ЗаполнитьТоварыПоТоварамВКоробахПеремещения()
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ПеремещениеТоваровгф_ТоварыВКоробах.УпаковочныйЛист КАК УпаковочныйЛистРодитель,
	|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
	|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
	|	УпаковочныйЛистТовары.Упаковка КАК Упаковка,
	|	УпаковочныйЛистТовары.КоличествоУпаковок КАК КоличествоУпаковок,
	|	УпаковочныйЛистТовары.Количество КАК Количество,
	|	УпаковочныйЛистТовары.ЭтоУпаковочныйЛист КАК ЭтоУпаковочныйЛист,
	|	УпаковочныйЛистТовары.Назначение КАК Назначение
	|ИЗ
	|	Документ.ПеремещениеТоваров.гф_ТоварыВКоробах КАК ПеремещениеТоваровгф_ТоварыВКоробах
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
	|		ПО ПеремещениеТоваровгф_ТоварыВКоробах.УпаковочныйЛист = УпаковочныйЛистТовары.Ссылка
	|ГДЕ
	|	ПеремещениеТоваровгф_ТоварыВКоробах.Ссылка = &Распоряжение
	|	И НЕ УпаковочныйЛистТовары.ЭтоУпаковочныйЛист
	|ИТОГИ ПО
	|	УпаковочныйЛистРодитель");
	
	Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
	РезультатПоУпаковочнымЛистам = Запрос.Выполнить();
	
	Если Не РезультатПоУпаковочнымЛистам.Пустой() Тогда
		Товары.Очистить();
		ВыборкаИтогиПоУпЛист = РезультатПоУпаковочнымЛистам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаИтогиПоУпЛист.Следующий() Цикл
			нс = Товары.Добавить();
			нс["УпаковочныйЛист"] = ВыборкаИтогиПоУпЛист.УпаковочныйЛистРодитель;
			нс["ЭтоУпаковочныйЛист"] = Истина;
			ВыборкаТовары = ВыборкаИтогиПоУпЛист.Выбрать();
			Пока ВыборкаТовары.Следующий() Цикл
				нс = Товары.Добавить();
				ЗаполнитьЗначенияСвойств(нс, ВыборкаТовары);
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьТоварыПоТоварамПеремещения()
	
	Запрос = Новый Запрос("ВЫБРАТЬ
|	ЗНАЧЕНИЕ(Документ.УпаковочныйЛист.ПустаяСсылка) КАК УпаковочныйЛистРодитель,
|	ПеремещениеТоваровТовары.Номенклатура КАК Номенклатура,
|	ПеремещениеТоваровТовары.Характеристика КАК Характеристика,
|	ПеремещениеТоваровТовары.Упаковка КАК Упаковка,
|	СУММА(ПеремещениеТоваровТовары.КоличествоУпаковок) КАК КоличествоУпаковок,
|	СУММА(ПеремещениеТоваровТовары.Количество) КАК Количество,
|	ПеремещениеТоваровТовары.Назначение КАК Назначение,
|	ЛОЖЬ КАК ЭтоУпаковочныйЛист
|ИЗ
|	Документ.ПеремещениеТоваров.Товары КАК ПеремещениеТоваровТовары
|ГДЕ
|	ПеремещениеТоваровТовары.Ссылка = &Распоряжение
|
|СГРУППИРОВАТЬ ПО
|	ПеремещениеТоваровТовары.Номенклатура,
|	ПеремещениеТоваровТовары.Характеристика,
|	ПеремещениеТоваровТовары.Упаковка,
|	ПеремещениеТоваровТовары.Назначение");
	
	Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
	Результат = Запрос.Выполнить();
	
	Если Не Результат.Пустой() Тогда
		Товары.Очистить();
		ВыборкаТовары = Результат.Выбрать();
		Пока ВыборкаТовары.Следующий() Цикл
			нс = Товары.Добавить();
			ЗаполнитьЗначенияСвойств(нс, ВыборкаТовары);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

// #wortmann { 
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee7ed187d3b8e2
// Необходимо не перезаполнять ТЧ для Виртуального отправителя
// Галфинд_Домнышева 2023/11/09
Функция ПроверкаСкладаНаВиртуальность(СкладОтправитель) 
	
	ВиртуальныеСклады = _омОбщегоНазначенияКлиентСервер.ПолучитьГлобальноеЗначениеМассив("гф_ВиртуальныеСклады");
	Если ВиртуальныеСклады.Найти(СкладОтправитель) <> Неопределено Тогда
        Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
	
КонецФункции// } #wortmann

#КонецОбласти

#КонецЕсли
#КонецЕсли