﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка) 
	
	гф_СоздатьНовыеРеквизиты();
		
	гф_УстановитьВидимостьИДоступность();
	
КонецПроцедуры

// #wortmann { Галфинд Sakovich 2022/09/01
&НаКлиенте
Процедура гф_ПриОткрытииПосле(Отказ)
	гф_ОбновитьЗаголовокСтраницы("Продукция в коробах", "гф_ПродукцияВКоробах", "гф_ГруппаПродукцияВКоробах");
КонецПроцедуры // } #wortmann

&НаКлиенте
Процедура гф_ПродукцияВКоробахПриИзменении(Элемент) 
	гф_УстановитьВидимостьИДоступность();
	гф_ОбновитьЗаголовокСтраницы("Продукция в коробах", "гф_ПродукцияВКоробах", "гф_ГруппаПродукцияВКоробах");
КонецПроцедуры

&НаКлиенте
Процедура гф_ПродукцияВКоробахIDКоробаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка) 

	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные = Элементы.гф_ПродукцияВКоробах.ТекущиеДанные;
	
	ПараметрыФормы = Новый Структура;
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("гф_Организация",Объект.Организация);
	ПараметрыОтбора.Вставить("гф_Поставка",ПредопределенноеЗначение("Документ.ПриобретениеТоваровУслуг.ПустаяСсылка"));
		
	Если ЗначениеЗаполнено(ТекущиеДанные.ВариантКомплектации) Тогда
		 ПараметрыОтбора.Вставить("гф_Комплектация", ТекущиеДанные.ВариантКомплектации);
	КонецЕсли;
	 
	ПараметрыФормы.Вставить("Отбор", ПараметрыОтбора);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("гф_ОбработкаВыбораИДКороба", ЭтотОбъект);
	
	ОткрытьФорму("Документ.УпаковочныйЛист.ФормаВыбора", ПараметрыФормы, ЭтотОбъект, , , , ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
			
	ОписаниеТиповУпаковочныйЛист		= Новый ОписаниеТипов("ДокументСсылка.УпаковочныйЛист");
	ОписаниеТиповЗаказКлиента  			= Новый ОписаниеТипов("ДокументСсылка.ЗаказКлиента");
	ОписаниеТиповРазмерностьОбуви		= Новый ОписаниеТипов("СправочникСсылка.ХарактеристикиНоменклатуры");
	
	ДобавляемыеРеквизиты = Новый Массив;
	
	РеквизитФормы_РазмерностьОбуви		= Новый РеквизитФормы("гф_РазмерностьОбуви",
										ОписаниеТиповРазмерностьОбуви, , "Размерность обуви", Истина);
										
	РеквизитФормы_гф_ЗаказКлиента		= Новый РеквизитФормы("гф_ЗаказКлиента",
										ОписаниеТиповЗаказКлиента, , "Заказ клиента", Истина);

	РеквизитФормы_гф_ИДКороба			= Новый РеквизитФормы("гф_ИДКороба",
										ОписаниеТиповУпаковочныйЛист, , "ИД короба", Истина);	
											
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ЗаказКлиента);
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ИДКороба); 
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_РазмерностьОбуви);
		
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ТипПолеФормы = Тип("ПолеФормы");
	
	// #wortmann { Галфинд Sakovich 2022/09/01
	ТипТаблицаФормы = Тип("ТаблицаФормы");
	ТипКнопкаФормы = Тип("КнопкаФормы");
	ТипГруппаФормы = Тип("ГруппаФормы");
	// } #wortmann
	
	НовоеПоле = Элементы.Добавить("гф_РазмерностьОбуви", ТипПолеФормы,
										Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_РазмерностьОбуви";
	
	НовоеПоле = Элементы.Добавить("гф_ЗаказКлиента", ТипПолеФормы,
										Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_ЗаказКлиента"; 	
		
	НовоеПоле = Элементы.Добавить("гф_ИДКороба", ТипПолеФормы,
										Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_IDКороба"; 
	
	Команда = Команды.Добавить("гф_ЗагрузитьИзВнешнегоФайла");
	Команда.Заголовок = "Загрузить из внешнего файла";
	Команда.Действие = "гф_ЗагрузитьИзВнешнегоФайла";
	
	Команда = Команды.Добавить("гф_ПересчитатьТовары");
	Команда.Заголовок = "Пересчитать товары";
	Команда.Действие = "гф_ПересчитатьТовары";
	
	// #wortmann {
	// вывод на форму тч ПродукцияВКоробах
	// Галфинд Sakovich 2022/09/01
	НовыйЭлемент = Элементы.Вставить("гф_ГруппаПродукцияВКоробах", ТипГруппаФормы,
		Элементы.ГруппаСтраницы, Элементы.ГруппаТовары);
    НовыйЭлемент.Вид = ВидГруппыФормы.Страница;
	НовыйЭлемент.Заголовок = "Товары в коробах";
	
	НовыйЭлемент = Элементы.Вставить("гф_ПродукцияВКоробах", ТипТаблицаФормы,
		Элементы.гф_ГруппаПродукцияВКоробах);
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах"; 
	НовыйЭлемент.УстановитьДействие("ПриИзменении", "гф_ПродукцияВКоробахПриИзменении");
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахНомерСтроки", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.НомерСтроки";
	НовыйЭлемент.Заголовок = " N ";
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахIDКороба", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.IDКороба"; 
	НовыйЭлемент.Заголовок = "IDКороба";
    НовыйЭлемент.УстановитьДействие("НачалоВыбора","гф_ПродукцияВКоробахIDКоробаНачалоВыбора");
		
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахВариантКомплектации", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.ВариантКомплектации"; 
	НовыйЭлемент.Заголовок = "Артикул с ростовкой (вариант комплектации)";
    	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахКоличествоКоробов", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.КоличествоКоробов"; 
	НовыйЭлемент.Заголовок = "Количество коробов";
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахЗаказПоставщику", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.ЗаказПоставщику"; 
	НовыйЭлемент.Заголовок = "Заказ поставщику";
	
	НоваяКоманда = Команды.Добавить("гф_ЗаполнитьЗаказПоставщику");
	НоваяКоманда.Заголовок = "Заполнить заказ поставщику";
	НоваяКоманда.Подсказка = "Заполнить заказ поставщику для выделенных строк";
	НоваяКоманда.Действие = "гф_ЗаполнитьЗаказПоставщику";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина;
	
	НовыйЭлемент = Элементы.Вставить("гф_ЗаполнитьЗаказПоставщику",
		ТипКнопкаФормы, Элементы.гф_ПродукцияВКоробах.КоманднаяПанель);
	НовыйЭлемент.Заголовок = "Заполнить заказ поставщику";
	НовыйЭлемент.ИмяКоманды = "гф_ЗаполнитьЗаказПоставщику";
	// } #wortmann
	
	НоваяКнопка = Элементы.Добавить("гф_ЗагрузитьИзВнешнегоФайла", Тип("КнопкаФормы"), 
								Элементы.гф_ПродукцияВКоробах.КоманднаяПанель);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗагрузитьИзВнешнегоФайла";
	
	НоваяКнопка = Элементы.Добавить("гф_ПересчитатьТовары", Тип("КнопкаФормы"), 
								Элементы.ТоварыЗаполнить);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПересчитатьТовары";
	
КонецПроцедуры	

&НаСервере
Процедура гф_УстановитьВидимостьИДоступность()
	
	Если ЗначениеЗаполнено(Объект.Склад) Тогда 
		ВидимостьСтраницыТоварыВКоробах();
	Иначе
		Элементы.гф_СтраницаТоварыВКоробах.Видимость = Ложь;
	КонецЕсли;
	
	Для каждого ЭлементКП из Элементы.Товары.КоманднаяПанель.ПодчиненныеЭлементы Цикл		
		Если  ЭлементКП.Имя = "ГруппаТоварыПодобратьТовары" Тогда                    		
			Для каждого ЭлементПодобрать из ЭлементКП.ПодчиненныеЭлементы Цикл       			
				Если ЭлементПодобрать.Имя = "ТоварыЗаполнить" Тогда                  				
					Для каждого ЭлементЗаполнить из ЭлементПодобрать.ПодчиненныеЭлементы Цикл						
						Если ЭлементЗаполнить.Имя = "гф_ПересчитатьТовары" Тогда 
							Продолжить;							
						КонецЕсли;
						ЭлементЗаполнить.Доступность = Объект.гф_ПродукцияВКоробах.Количество() = 0;
					КонецЦикла;	
					Продолжить;
				КонецЕсли;	           			
				ЭлементПодобрать.Доступность = Объект.гф_ПродукцияВКоробах.Количество() = 0;
			КонецЦикла;	
			Продолжить;
		КонецЕсли;	                   	
		ЭлементКП.Доступность = Объект.гф_ПродукцияВКоробах.Количество() = 0;
	КонецЦикла;
	
	Элементы.Товары.ТолькоПросмотр = Объект.гф_ПродукцияВКоробах.Количество() <> 0;
		
КонецПроцедуры

&НаСервере
Процедура ВидимостьСтраницыТоварыВКоробах() 
		
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Товары в коробах"); 
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Объект.Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Истина; 
	Иначе
		 Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Ложь;
		 Объект.гф_ПродукцияВКоробах.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ЗначениеРеквизитаОбъекта(Объект,ИмяРеквизита)
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект,ИмяРеквизита);	
КонецФункции

&НаКлиенте
Процедура гф_ОбработкаВыбораИДКороба(ВыбранноеЗначение, ДополнительныеПараметры) Экспорт
	
	Если ВыбранноеЗначение <> Неопределено Тогда
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.IDКороба = ВыбранноеЗначение;
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.ВариантКомплектации = 
										ЗначениеРеквизитаОбъекта(ВыбранноеЗначение,"гф_Комплектация");
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.КоличествоКоробов = 1;
	КонецЕсли;	
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ЗагрузитьИзВнешнегоФайла(Команда)
	
	Если Объект.Товары.Количество() > 0
		ИЛИ Объект.гф_ПродукцияВКоробах.Количество() > 0 Тогда
		ТекстВопроса = НСтр("ru='Табличные части ""Товары"" и ""Продукция в коробах"" будет очищена. Продолжить?'");
		ДопПараметры = Новый Структура() ;
		Оповещение = Новый ОписаниеОповещения("гф_ВопросЗагрузитьПродукцияВКоробахЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		гф_ЗагрузитьИзВнешнегоФайлаПродукцияВКоробахПродолжение();
	КонецЕсли;	
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ПересчитатьТовары(Команда)
	
	Если Объект.Товары.Количество() > 0 Тогда
		ТекстВопроса = НСтр("ru='Табличные части ""Товары"" будет очищена. Продолжить?'");
		ДопПараметры = Новый Структура() ;
		Оповещение = Новый ОписаниеОповещения("гф_ВопросПересчитатьТоварыЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		гф_ОбработатьТоврыПриЗагрузкеИзФайла();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ВопросПересчитатьТоварыЗавершение (Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		Объект.Товары.Очистить();
		гф_ОбработатьТоврыПриЗагрузкеИзФайла();	
	КонецЕсли;

КонецПроцедуры	

&НаКлиенте 
Процедура гф_ВопросЗагрузитьПродукцияВКоробахЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		гф_ЗагрузитьИзВнешнегоФайлаПродукцияВКоробахПродолжение();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ЗагрузитьИзВнешнегоФайлаПродукцияВКоробахПродолжение()
	ПараметрыЗагрузки = ЗагрузкаДанныхИзФайлаКлиент.ПараметрыЗагрузкиДанных();
	ПараметрыЗагрузки.ПолноеИмяТабличнойЧасти = "ПриобретениеТоваровУслуг.гф_ПродукцияВКоробах";
	ПараметрыЗагрузки.Заголовок = НСтр("ru = 'Загрузка данных из файла'");
	ДополнительныеПараметры = Новый Структура();
	ПараметрыЗагрузки.ДополнительныеПараметры = ДополнительныеПараметры;
	Оповещение = Новый ОписаниеОповещения("гф_ЗагрузитьИзВнешнегоФайлаПродукцияВКоробахЗавершение", ЭтотОбъект);
	ЗагрузкаДанныхИзФайлаКлиент.ПоказатьФормуЗагрузки(ПараметрыЗагрузки, Оповещение);
КонецПроцедуры 

&НаКлиенте
Процедура гф_ЗагрузитьИзВнешнегоФайлаПродукцияВКоробахЗавершение(АдресЗагруженныхДанных, 
	ДополнительныеПараметры) Экспорт
	
	Если АдресЗагруженныхДанных = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	гф_ЗагрузитьВариантыКомплектацииИзФайлаНаСервере(АдресЗагруженныхДанных);
	
	//Для каждого стрКоллекции Из Объект.ВыходныеИзделия Цикл
	//		гф_ЗаполнитьНазначениеПолучательПоУмолчанию(стрКоллекции);
	//КонецЦикла;
	
	//гф_ТаблицаНоменклатураПриИзменении("ВыходныеИзделия", "Получатель");
	//гф_ТаблицаКоличествоУпаковокПриИзменении("ВыходныеИзделия");	
	//гф_ОбновитьЗаголовокСтраницы("Продукция в коробах", "гф_ПродукцияВКоробах", "гф_ГруппаПродукцияВКоробах");
	//КоличествоИзделий = Объект.ВыходныеИзделия.Количество();

КонецПроцедуры

&НаСервере
Процедура гф_ЗагрузитьВариантыКомплектацииИзФайлаНаСервере(АдресЗагруженныхДанных)
	Объект.гф_ПродукцияВКоробах.Очистить();
	Объект.Товары.Очистить();
	ЗагруженныеДанные = ПолучитьИзВременногоХранилища(АдресЗагруженныхДанных);
	
	ВариантыКомплектацииДобавлены = Ложь;
	Для каждого СтрокаТаблицы Из ЗагруженныеДанные Цикл 
		
		Если Не ЗначениеЗаполнено(СтрокаТаблицы.ВариантКомплектации) Тогда 
			Продолжить;
		КонецЕсли;
		
		НоваяСтрокаКомплектации = Объект.гф_ПродукцияВКоробах.Добавить();
		НоваяСтрокаКомплектации.ВариантКомплектации = СтрокаТаблицы.ВариантКомплектации;
		НоваяСтрокаКомплектации.IDКороба = СтрокаТаблицы.IDКороба;
		НоваяСтрокаКомплектации.КоличествоКоробов = СтрокаТаблицы.КоличествоКоробов;
		
		ВариантыКомплектацииДобавлены = Истина;
	КонецЦикла;
	
	Если ВариантыКомплектацииДобавлены Тогда
		Модифицированность = Истина;
	КонецЕсли;
	
	гф_ОбработатьТоврыПриЗагрузкеИзФайла();
	
КонецПроцедуры

&НаСервере
Процедура гф_ОбработатьТоврыПриЗагрузкеИзФайла() 
	ЦенаВПоставке = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ЦенаВПоставке").Значение;
	ПродукцияВКоробах = Объект.гф_ПродукцияВКоробах.Выгрузить();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ДокТч.ВариантКомплектации КАК ВариантКомплектации,
	|	ДокТч.КоличествоКоробов КАК КоличествоКоробов,
	|	ДокТч.ЗаказПоставщику КАК ЗаказПоставщику
	|ПОМЕСТИТЬ тч
	|ИЗ
	|	&ПродукцияВКоробах КАК ДокТч
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	тч.ВариантКомплектации КАК ВариантКомплектации,
	|	СУММА(тч.КоличествоКоробов) КАК КоличествоКоробов
	|ПОМЕСТИТЬ Короба
	|ИЗ
	|	тч КАК тч
	|
	|СГРУППИРОВАТЬ ПО
	|	тч.ВариантКомплектации
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Комплектация.Номенклатура КАК Номенклатура,
	|	Комплектация.Упаковка КАК Упаковка,
	|	Комплектация.КоличествоУпаковок КАК КоличествоУпаковок,
	|	Комплектация.ДоляСтоимости КАК ДоляСтоимости,
	|	Комплектация.Количество КАК Количество,
	|	Короба.ВариантКомплектации КАК ВариантКомплектации,
	|	Короба.КоличествоКоробов КАК КоличествоКоробов,
	|	Комплектация.Характеристика КАК Характеристика
	|ИЗ
	|	Короба КАК Короба
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыКомплектацииНоменклатуры.Товары КАК Комплектация
	|		ПО Короба.ВариантКомплектации = Комплектация.Ссылка
	|ИТОГИ
	|	МАКСИМУМ(КоличествоКоробов)
	|ПО
	|	ВариантКомплектации";
	Запрос.УстановитьПараметр("ПродукцияВКоробах", ПродукцияВКоробах);
	Результат = Запрос.Выполнить();
	ВыборкаКомплектация = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	ТоварыДобавлены = Ложь;
	
	Пока ВыборкаКомплектация.Следующий() Цикл
		КоличествоКоробов = ВыборкаКомплектация.КоличествоКоробов;
		Если КоличествоКоробов > 0 Тогда
			
			Для Сч = 1 По КоличествоКоробов Цикл
				Выборка = ВыборкаКомплектация.Выбрать();
				Пока Выборка.Следующий() Цикл
					Если Не ЗначениеЗаполнено(Выборка.Номенклатура) Тогда 
						Продолжить;
					КонецЕсли;
					
					НоваяСтрокаТовары = Объект.Товары.Добавить();
					НоваяСтрокаТовары.Номенклатура = Выборка.Номенклатура;
					НоваяСтрокаТовары.КоличествоУпаковок = Выборка.КоличествоУпаковок;
															
					НоваяСтрокаТовары.Упаковка = Выборка.Упаковка;
					//НоваяСтрокаТовары.ДоляСтоимости = Выборка.ДоляСтоимости;
					//НоваяСтрокаТовары.ДоляСтоимости = Выборка.ДоляСтоимости;
					НоваяСтрокаТовары.Количество = Выборка.Количество;
					НоваяСтрокаТовары.Характеристика = Выборка.Характеристика;
					НоваяСтрокаТовары.гф_РазмерностьОбуви = Выборка.ВариантКомплектации.Характеристика;
					ТоварыДобавлены = Истина;
				КонецЦикла;
			КонецЦикла;
		КонецЕсли;	
		
		Если ТоварыДобавлены Тогда
			Модифицированность = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Таблица = Объект.Товары.Выгрузить();
	Таблица.Свернуть("Номенклатура, Упаковка, Характеристика, гф_РазмерностьОбуви", "КоличествоУпаковок, Количество");
	Объект.Товары.Загрузить(Таблица);
	
	Для каждого СтрокаТЧ из Объект.Товары Цикл
		
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура", СтрокаТЧ.Номенклатура);	
		Отбор.Вставить("ВидЦены", ЦенаВПоставке);
		
		СтрокаТЧ.Цена = РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
			
	КонецЦикла;
	
	ПараметрыЗаполненияРеквизитов = Новый Структура;	
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются",
												Новый Структура("Номенклатура", "ХарактеристикиИспользуются"));
	НоменклатураСервер.ЗаполнитьСлужебныеРеквизитыПоНоменклатуреВКоллекции(Объект.Товары, ПараметрыЗаполненияРеквизитов);
	
	СтруктураПересчетаСуммы = ОбработкаТабличнойЧастиКлиентСервер.ПараметрыПересчетаСуммыНДСВСтрокеТЧ(Объект);
	
	СтруктураДействий = Новый Структура; 
		
	СтруктураДействий.Вставить("ЗаполнитьСтавкуНДС", ОбработкаТабличнойЧастиКлиентСервер.ПараметрыЗаполненияСтавкиНДС(
																											Объект,
																											Истина));
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСумму");
	СтруктураДействий.Вставить("ПересчитатьСумму");
	ОбработкаТабличнойЧастиСервер.ОбработатьТЧ(Объект.Товары, СтруктураДействий, Неопределено);	
			
КонецПроцедуры

&НаКлиенте
Процедура гф_ОбновитьЗаголовокСтраницы(Заголовок, ИмяТЧ, ИмяСтраницы)
	Элементы[ИмяСтраницы].Заголовок = 
	?(Объект[ИмяТЧ].Количество() = 0, Заголовок, Заголовок + " (" 
	+ Объект[ИмяТЧ].Количество() + ")");
КонецПроцедуры

&НаКлиенте
Процедура гф_ЗаполнитьЗаказПоставщику(Команда)
	мВыделенныхСтрок = Элементы.гф_ПродукцияВКоробах.ВыделенныеСтроки;
	Если мВыделенныхСтрок.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	ДополнительныеПараметры	 = Новый Структура;
	ДополнительныеПараметры.Вставить("ВыделенныеСтроки", мВыделенныхСтрок);
	Оповещение = Новый ОписаниеОповещения("гф_ЗаполнитьЗаказПоставщикуЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	Отбор = Новый Структура("Организация", Объект.Организация);
	П = Новый Структура;
	П.Вставить("Отбор", Отбор);
	ОткрытьФорму("Документ.ЗаказПоставщику.ФормаВыбора", П, ЭтотОбъект, , , ,
		Оповещение, РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
КонецПроцедуры

&НаКлиенте
Процедура гф_ЗаполнитьЗаказПоставщикуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	мВыделенныхСтрок = ДополнительныеПараметры.ВыделенныеСтроки;
	Для каждого Эл Из мВыделенныхСтрок Цикл
		стрТЧ = Объект.гф_ПродукцияВКоробах.НайтиПоИдентификатору(Эл);
		Если стрТЧ = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		стрТЧ.ЗаказПоставщику = Результат;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура гф_СкладПриИзмененииПосле(Элемент)
	ВидимостьСтраницыТоварыВКоробах();
КонецПроцедуры

#КонецОбласти