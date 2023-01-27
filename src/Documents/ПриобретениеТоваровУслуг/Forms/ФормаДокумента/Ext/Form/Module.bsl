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

// #wortmann {
// Галфинд Sakovich 2022/12/19
&НаКлиенте
Процедура гф_NVE_назначенПриИзменении(Элемент)
	Если Не Объект.гф_NVE_назначен Тогда
		ТекстВопроса = НСтр("ru='Будет снят признак ""NVE назначен"" для всех коробов поставки. Продолжить?'");
		ДопПараметры = Новый Структура() ;
		Оповещение = Новый ОписаниеОповещения("гф_ВопросСнятьNVEНазначенЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	КонецЕсли;
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

&НаКлиенте
&Вместо("Подключаемый_ВыполнитьКоманду")
Процедура гф_Подключаемый_ВыполнитьКоманду(Команда)
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8129bcee7bda45d711ed9af2afe009b2
	// Запрет печати Импорт 40 по условию
	// Галфинд Sakovich 2023/01/23
	Если СтрНайти(Врег(Команда.Имя), "ПФ_ИМПОРТ40") > 0 Тогда
		ПоставкаЗакрыта =  ОпределитьЗакрытаЛиПоставка();
		Если Не ПоставкаЗакрыта Тогда
			ПоказатьПредупреждение(,  "Поставка не закрыта. Печать Импорт 40 невозможна", , "Печать");
			Возврат;
		Иначе
			ПродолжитьВызов(Команда);
		КонецЕсли;
	Иначе
		ПродолжитьВызов(Команда);
	КонецЕсли;
	// } #wortmann
КонецПроцедуры 

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере 
Функция ОпределитьЗакрытаЛиПоставка()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	гф_СтатусОтгрузкиСрезПоследних.ГотовоКПодачеГТД КАК ГотовоКПодачеГТД
	|ИЗ
	|	РегистрСведений.гф_СтатусОтгрузки.СрезПоследних(, Документ = &Документ) КАК гф_СтатусОтгрузкиСрезПоследних";
	Запрос.УстановитьПараметр("Документ", Объект.Ссылка);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Выборка.Следующий();
	Возврат Выборка["ГотовоКПодачеГТД"];
	
КонецФункции 


&НаКлиенте
Процедура гф_ВопросСнятьNVEНазначенЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		гф_СброситьПризнакNVE_назначен_для_УЛ();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура гф_СброситьПризнакNVE_назначен_для_УЛ()
    тзУл = Объект.гф_ПродукцияВКоробах.Выгрузить();
	мУл = тзУл.ВыгрузитьКолонку("IDКороба");
		Для каждого Эл Из мУл Цикл
		Если Не ЗначениеЗаполнено(Эл) Тогда
			Продолжить;
		КонецЕсли;
		Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Эл, "гф_NVE_назначен") = Ложь Тогда
			Продолжить;
		КонецЕсли;
		обУл = Эл.ПолучитьОбъект();
		Если обУл <> Неопределено Тогда
			обУл.гф_NVE_назначен = Ложь;
			Попытка
				обУл.Записать();
			Исключение
				ОбщегоНазначения.СообщитьПользователю("Не удалось снять признак ""NVE назначен"" у документа " + Эл);
			КонецПопытки;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

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
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахСтоимостьКороба", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.СтоимостьКороба"; 
	НовыйЭлемент.Заголовок = "Стоимость короба";
	
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
	
	НоваяКоманда = Команды.Добавить("гф_ОбработатьУпаковочныеЛисты");
	НоваяКоманда.Заголовок = "Обработать упаковочные листы";
	НоваяКоманда.Подсказка = "Создать и заполнить упаковочные листы в строках";
	НоваяКоманда.Действие = "гф_ОбработатьУпаковочныеЛисты";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина;
	
	НовыйЭлемент = Элементы.Вставить("гф_ОбработатьУпаковочныеЛисты",
		ТипКнопкаФормы, Элементы.гф_ПродукцияВКоробах.КоманднаяПанель);
	НовыйЭлемент.Заголовок = "Обработать упаковочные листы";
	НовыйЭлемент.ИмяКоманды = "гф_ОбработатьУпаковочныеЛисты";
	// vvv Галфинд \ Sakovich 11.12.2022
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed77ea01e7705f
	// скрываем команду:
	НовыйЭлемент.Видимость = Ложь;
	// ^^^ Галфинд \ Sakovich 11.12.2022 
	
	// } #wortmann
	
	НоваяКнопка = Элементы.Добавить("гф_ЗагрузитьИзВнешнегоФайла", Тип("КнопкаФормы"), 
								Элементы.гф_ПродукцияВКоробах.КоманднаяПанель);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗагрузитьИзВнешнегоФайла";
	
	НоваяКнопка = Элементы.Добавить("гф_ПересчитатьТовары", Тип("КнопкаФормы"), 
	Элементы.ТоварыЗаполнить);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПересчитатьТовары";
	
	// #wortmann {
	// Галфинд Sakovich 2022/11/30
	НовыйЭлемент = Элементы.Вставить("гф_ГруппаЭмиссияКМ", ТипГруппаФормы,
	Элементы.ГруппаОсновное, Элементы.ГруппаШапка);
	НовыйЭлемент.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	НовыйЭлемент.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяЕслиВозможно;
	НовыйЭлемент.ЦветФона = WebЦвета.Перламутровый;
	НовыйЭлемент.ОтображатьЗаголовок = Ложь;
	
	НовыйЭлемент = Элементы.Вставить("гф_ЗаказатьКМ", ТипПолеФормы,
	Элементы.гф_ГруппаЭмиссияКМ);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ЗаказатьКМ"; 
	НовыйЭлемент.Заголовок = "Заказать КМ";

	НовыйЭлемент = Элементы.Вставить("гф_КМЭмитированы", ТипПолеФормы,
	Элементы.гф_ГруппаЭмиссияКМ);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
    НовыйЭлемент.ПутьКДанным = "Объект.гф_КМЭмитированы"; 
	НовыйЭлемент.Заголовок = "КМ эмитированы";
	НовыйЭлемент.ТолькоПросмотр = Истина;
	// } #wortmann
	
	// #wortmann {
	// Галфинд Sakovich 2022/12/19
	НовыйЭлемент = Элементы.Вставить("гф_NVE_назначен", ТипПолеФормы);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
    НовыйЭлемент.ПутьКДанным = "Объект.гф_NVE_назначен"; 
	НовыйЭлемент.УстановитьДействие("ПриИзменении", "гф_NVE_назначенПриИзменении");
	// } #wortmann
		
КонецПроцедуры	

&НаСервере
Процедура гф_УстановитьВидимостьИДоступность()
	
	Если ЗначениеЗаполнено(Объект.Склад) Тогда 
		ВидимостьСтраницыТоварыВКоробах();
	Иначе
		Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Ложь;
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
	
	//- Отказ от использования. Аналитик Гришина Ксения
	//Элементы.Товары.ТолькоПросмотр = Объект.гф_ПродукцияВКоробах.Количество() <> 0;
	
	// #wortmann {
	// Галфинд Sakovich 2022/11/30
	гф_ДоступностьЭлементовГруппыЭмиссияКМ();
	// } #wortmann
	
	// #wortmann {
	// Галфинд Sakovich 2022/12/19
	гф_ВидимостьЭлементаNVE_назначен();
	// } #wortmann
	
КонецПроцедуры

&НаСервере
Процедура гф_ВидимостьЭлементаNVE_назначен()

	Элементы.гф_NVE_назначен.Видимость = 
	(ЗначениеЗаполнено(Объект.Склад)
	И УправлениеСвойствами.ЗначениеСвойства(Склад, "гф_СкладыТоварыВКоробах") = Истина);

КонецПроцедуры

&НаСервере
Процедура гф_ЗначениеФлагаЗаказатьКМ()

	ЕстьМаркируемаяПродукция = гф_ОпределитьНаличиеМаркируемойПродукции();
	Объект.гф_ЗаказатьКМ = ЕстьМаркируемаяПродукция;

КонецПроцедуры

&НаСервере
Процедура гф_ДоступностьЭлементовГруппыЭмиссияКМ()

	ДоступностьГруппыЭмиссияКМ = Не Объект.гф_КМЭмитированы;
	Элементы.гф_ГруппаЭмиссияКМ.Доступность = ДоступностьГруппыЭмиссияКМ;
	Если Не ДоступностьГруппыЭмиссияКМ Тогда
		Возврат;
	КонецЕсли;
	ЕстьМаркируемаяПродукция = гф_ОпределитьНаличиеМаркируемойПродукции();
	Элементы.гф_ГруппаЭмиссияКМ.Доступность = ЕстьМаркируемаяПродукция;

КонецПроцедуры

&НаСервере
Функция гф_ОпределитьНаличиеМаркируемойПродукции() Экспорт
	
	тзТовары = Объект.Товары.Выгрузить();	
	ЕстьМаркируемаяПродукция = Документы.ПриобретениеТоваровУслуг.гф_ОпределитьНаличиеМаркируемойПродукции(тзТовары);
	Возврат ЕстьМаркируемаяПродукция;
	
КонецФункции

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
				
		Для каждого Строка Из Объект.Товары Цикл 
			СтруктураДействий = Новый Структура;
			СтруктураДействий.Вставить("ЗаполнитьПризнакАртикул", Новый Структура("Номенклатура", "Артикул"));
			СтруктураДействий.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются", 
												Новый Структура("Номенклатура", "ХарактеристикиИспользуются"));
						
			ОбработкаТабличнойЧастиКлиент.ОбработатьСтрокуТЧ(Строка, СтруктураДействий, КэшированныеЗначения);
		КонецЦикла	
		
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
	//+Developer2 ТЗ ПТУ Изменение аналитик Алексей
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.гф_ПересчитатьТЧТоварыНаОсновнииКоробов();
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект"); 
			
	Модифицированность = Истина;
	//+Developer2 ТЗ ПТУ Изменение аналитик Алексей
	//-Developer2 ТЗ ПТУ Изменение аналитик Алексей
	//ЦенаВПоставке = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
	//							"Ключ", "гф_ЦенаВПоставке").Значение;
	//ПродукцияВКоробах = Объект.гф_ПродукцияВКоробах.Выгрузить();
	//Запрос = Новый Запрос;
	//Запрос.Текст = "ВЫБРАТЬ
	//|	ДокТч.ВариантКомплектации КАК ВариантКомплектации,
	//|	ДокТч.КоличествоКоробов КАК КоличествоКоробов,
	//|	ДокТч.ЗаказПоставщику КАК ЗаказПоставщику
	//|ПОМЕСТИТЬ тч
	//|ИЗ
	//|	&ПродукцияВКоробах КАК ДокТч
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	//|ВЫБРАТЬ
	//|	тч.ВариантКомплектации КАК ВариантКомплектации,
	//|	СУММА(тч.КоличествоКоробов) КАК КоличествоКоробов
	//|ПОМЕСТИТЬ Короба
	//|ИЗ
	//|	тч КАК тч
	//|
	//|СГРУППИРОВАТЬ ПО
	//|	тч.ВариантКомплектации
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	//|ВЫБРАТЬ
	//|	Комплектация.Номенклатура КАК Номенклатура,
	//|	Комплектация.Упаковка КАК Упаковка,
	//|	Комплектация.КоличествоУпаковок КАК КоличествоУпаковок,
	//|	Комплектация.ДоляСтоимости КАК ДоляСтоимости,
	//|	Комплектация.Количество КАК Количество,
	//|	Короба.ВариантКомплектации КАК ВариантКомплектации,
	//|	Короба.КоличествоКоробов КАК КоличествоКоробов,
	//|	Комплектация.Характеристика КАК Характеристика
	//|ИЗ
	//|	Короба КАК Короба
	//|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыКомплектацииНоменклатуры.Товары КАК Комплектация
	//|		ПО Короба.ВариантКомплектации = Комплектация.Ссылка
	//|ИТОГИ
	//|	МАКСИМУМ(КоличествоКоробов)
	//|ПО
	//|	ВариантКомплектации";
	//Запрос.УстановитьПараметр("ПродукцияВКоробах", ПродукцияВКоробах);
	//Результат = Запрос.Выполнить();
	//ВыборкаКомплектация = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	//
	//ТоварыДобавлены = Ложь;
	//
	//Пока ВыборкаКомплектация.Следующий() Цикл
	//	КоличествоКоробов = ВыборкаКомплектация.КоличествоКоробов;
	//	Если КоличествоКоробов > 0 Тогда
	//		
	//		Для Сч = 1 По КоличествоКоробов Цикл
	//			Выборка = ВыборкаКомплектация.Выбрать();
	//			Пока Выборка.Следующий() Цикл
	//				Если Не ЗначениеЗаполнено(Выборка.Номенклатура) Тогда 
	//					Продолжить;
	//				КонецЕсли;
	//				
	//				НоваяСтрокаТовары = Объект.Товары.Добавить();
	//				НоваяСтрокаТовары.Номенклатура = Выборка.Номенклатура;
	//				НоваяСтрокаТовары.КоличествоУпаковок = Выборка.КоличествоУпаковок;
	//														
	//				НоваяСтрокаТовары.Упаковка = Выборка.Упаковка;
	//				//НоваяСтрокаТовары.ДоляСтоимости = Выборка.ДоляСтоимости;
	//				//НоваяСтрокаТовары.ДоляСтоимости = Выборка.ДоляСтоимости;
	//				НоваяСтрокаТовары.Количество = Выборка.Количество;
	//				НоваяСтрокаТовары.Характеристика = Выборка.Характеристика;
	//				НоваяСтрокаТовары.гф_РазмерностьОбуви = Выборка.ВариантКомплектации.Характеристика;
	//				ТоварыДобавлены = Истина;
	//			КонецЦикла;
	//		КонецЦикла;
	//	КонецЕсли;	
	//	
	//	Если ТоварыДобавлены Тогда
	//		Модифицированность = Истина;
	//	КонецЕсли;
	//КонецЦикла;
	//
	//Таблица = Объект.Товары.Выгрузить();
	//Таблица.Свернуть("Номенклатура, Упаковка, Характеристика, гф_РазмерностьОбуви", "КоличествоУпаковок, Количество");
	//Объект.Товары.Загрузить(Таблица);
	//
	//Для каждого СтрокаТЧ из Объект.Товары Цикл
	//	
	//	Отбор = Новый Структура;
	//	Отбор.Вставить("Номенклатура", СтрокаТЧ.Номенклатура);	
	//	Отбор.Вставить("ВидЦены", ЦенаВПоставке);
	//	
	//	СтрокаТЧ.Цена = РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
	//	
	//	СтрокаТЧ.Склад = Объект.Склад;
	//		
	//КонецЦикла;
	//
	//ПараметрыЗаполненияРеквизитов = Новый Структура;	
	//ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются",
	//											Новый Структура("Номенклатура", "ХарактеристикиИспользуются"));
	//НоменклатураСервер.ЗаполнитьСлужебныеРеквизитыПоНоменклатуреВКоллекции(Объект.Товары, ПараметрыЗаполненияРеквизитов);
	//
	//СтруктураПересчетаСуммы = ОбработкаТабличнойЧастиКлиентСервер.ПараметрыПересчетаСуммыНДСВСтрокеТЧ(Объект);
	//
	//СтруктураДействий = Новый Структура; 
	//	
	//СтруктураДействий.Вставить("ЗаполнитьСтавкуНДС", ОбработкаТабличнойЧастиКлиентСервер.ПараметрыЗаполненияСтавкиНДС(
	//																										Объект,
	//																										Истина));
	//СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
	//СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчетаСуммы);
	//СтруктураДействий.Вставить("ПересчитатьСумму");
	//СтруктураДействий.Вставить("ПересчитатьСумму");
	//ОбработкаТабличнойЧастиСервер.ОбработатьТЧ(Объект.Товары, СтруктураДействий, Неопределено);	
	//-Developer2 ТЗ ПТУ Изменение аналитик Алексей		
КонецПроцедуры

&НаКлиенте
Процедура гф_ОбновитьЗаголовокСтраницы(Заголовок, ИмяТЧ, ИмяСтраницы)
	Элементы[ИмяСтраницы].Заголовок = 
	?(Объект[ИмяТЧ].Количество() = 0, Заголовок, Заголовок + " (" 
	+ Объект[ИмяТЧ].Количество() + ")");
КонецПроцедуры

&НаСервере
Функция ПолучитьСвободныеСерийныеНомера()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	гф_ЗагруженныеСерийныеНомера.Наименование КАК Наименование
	|ИЗ
	|	РегистрСведений.гф_ЗагруженныеСерийныеНомера КАК гф_ЗагруженныеСерийныеНомера
	|ГДЕ
	|	НЕ гф_ЗагруженныеСерийныеНомера.Использован
	|
	|УПОРЯДОЧИТЬ ПО
	|	Наименование";
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;
	
КонецФункции // ()

&НаСервере
Процедура ОбработатьУпаковочныеЛистыНаСервере()
	
	тзПродукцияВКоробах = Объект.гф_ПродукцияВКоробах.Выгрузить();
	мСтрокДляСозданияУпЛистов = Новый Массив;
	мСтрокДляРазмножения = Новый Массив;
	Для каждого стрТз Из тзПродукцияВКоробах Цикл
		Если ЗначениеЗаполнено(стрТз["ВариантКомплектации"]) И стрТз["КоличествоКоробов"] > 1 Тогда
			мСтрокДляРазмножения.Добавить(стрТз);
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Эл Из мСтрокДляРазмножения Цикл
		Для Сч = 1 По Эл["КоличествоКоробов"] Цикл
			нс = тзПродукцияВКоробах.Вставить(тзПродукцияВКоробах.Индекс(Эл));
			ЗаполнитьЗначенияСвойств(нс, Эл);
			нс["КоличествоКоробов"] = 1;
			Если Сч > 1 Тогда
				нс["IDКороба"] = "";
			КонецЕсли;
		КонецЦикла;
		тзПродукцияВКоробах.Удалить(Эл);
	КонецЦикла;
	Для каждого стрТз Из тзПродукцияВКоробах Цикл

		Если Не ЗначениеЗаполнено(стрТз["IDКороба"]) Тогда
			мСтрокДляСозданияУпЛистов.Добавить(стрТз);
		КонецЕсли;
	КонецЦикла;
	
	ОшибкаПодбораСерийногоНомера = Ложь;
	мЗадействованныхСерийныхНомеров = Новый Массив;
	ОрганизацияУпЛиста = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Ссылка, "Организация");
	СлужебноеНазначение = Справочники.Назначения.гф_Техническое;
	
	Для каждого строкаУпЛист Из мСтрокДляСозданияУпЛистов Цикл
		
		РезультатЗапроса = ПолучитьСвободныеСерийныеНомера();
		
		Если РезультатЗапроса.Пустой() Тогда
			ОбщегоНазначения.СообщитьПользователю("Не найден свободный Серийный номер для создания УпаковочногоЛиста");
			ОшибкаПодбораСерийногоНомера = Истина;
			Продолжить;
		КонецЕсли;
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		мЗадействованныхСерийныхНомеров.Добавить(Выборка["Наименование"]);
		МенеджерЗаписи = РегистрыСведений.гф_ЗагруженныеСерийныеНомера.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Наименование = Выборка["Наименование"];
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() Тогда
			МенеджерЗаписи.Использован = Истина;
			МенеджерЗаписи.Записать();
		КонецЕсли;
		
		ДокУпЛист = Документы.УпаковочныйЛист.СоздатьДокумент();
		ДокУпЛист.Дата = ТекущаяДатаСеанса();
		ДокУпЛист.Код = Выборка["Наименование"];
		ДокУпЛист.Вид = Перечисления.ВидыУпаковочныхЛистов.Входящий;
		ДокУпЛист.гф_СостояниеКороба = Справочники.гф_СостянияКоробов.ПолныйКомплект;
		ДокУпЛист.гф_Комплектация = строкаУпЛист.ВариантКомплектации;
		ДокУпЛист.гф_Организация = ОрганизацияУпЛиста;
		ДокУпЛист.гф_Поставка = Объект.Ссылка;
		тчВариантКомплектации = строкаУпЛист["ВариантКомплектации"]["Товары"].Выгрузить();
		Для каждого стрТч Из тчВариантКомплектации Цикл
			нс = ДокУпЛист.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(нс, стрТч, "Номенклатура, Характеристика, Упаковка, КоличествоУпаковок");
			нс.ЭтоУпаковочныйЛист = Ложь;
			нс.Назначение = СлужебноеНазначение;
		КонецЦикла;
		
		Попытка
			ДокУпЛист.Записать(РежимЗаписиДокумента.Проведение);
			строкаУпЛист["IDКороба"] = ДокУпЛист.Ссылка;
		Исключение
			
			Попытка
				ДокУпЛист.Записать(РежимЗаписиДокумента.Запись);
				строкаУпЛист["IDКороба"] = ДокУпЛист.Ссылка;
			Исключение
				МенеджерЗаписи = РегистрыСведений.гф_ЗагруженныеСерийныеНомера.СоздатьМенеджерЗаписи();
				МенеджерЗаписи.Наименование = Выборка["Наименование"];
				МенеджерЗаписи.Прочитать();
				Если МенеджерЗаписи.Выбран() Тогда
					МенеджерЗаписи.Использован = Ложь;
					МенеджерЗаписи.Записать();
				КонецЕсли;
			КонецПопытки;
			
		КонецПопытки;
		
	КонецЦикла;	
	
	Объект.гф_ПродукцияВКоробах.Загрузить(тзПродукцияВКоробах);
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ОбработатьУпаковочныеЛисты(Команда)
	ОбработатьУпаковочныеЛистыНаСервере();
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
	
	// #wortmann {
	// Галфинд Sakovich 2022/12/19
	гф_ВидимостьЭлементаNVE_назначен();
	// } #wortmann
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ТоварыПриИзмененииПосле(Элемент)
	гф_ЗначениеФлагаЗаказатьКМ();
	гф_ДоступностьЭлементовГруппыЭмиссияКМ();
КонецПроцедуры

#КонецОбласти